#property copyright "Custom"
#property link      "https://www.mql5.com"
#property version   "1.20"
#property indicator_separate_window

// 실제 차트에 그려지는 플롯은 2개 (히스토그램, 스퀴즈 점)
// 하지만 색상 인덱스를 위해 총 4개의 버퍼가 필요함
#property indicator_buffers 6
#property indicator_plots   2

// 1. 모멘텀 히스토그램 설정
#property indicator_label1  "Momentum"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver, clrDimGray, clrSilver, clrDimGray // 0:상승가속, 1:상승감속, 2:하락가속, 3:하락감속
#property indicator_width1  1

// 2. 스퀴즈 상태 점 설정
#property indicator_label2  "Squeeze Dots"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrRed, clrGreen // 0:Squeeze On, 1:Squeeze Off
#property indicator_width2  1

// 파라미터
input int    InpPeriod = 20;   // Period (BB, KC, Mom 동일 적용)
input double InpBBMult = 2.0;  // BB 승수
input double InpKCMult = 1.5;  // KC 승수

// 지표 버퍼
double buffMomHist[], buffMomColor[]; // 히스토그램 데이터 & 색상
double buffSqzDots[], buffSqzColor[]; // 스퀴즈 점 데이터 & 색상
double buffMomSrc[],  buffMomLinReg[]; // 내부 계산용

// 핸들
int handleSMA, handleStdDev, handleATR;

//+------------------------------------------------------------------+
int OnInit()
{
   // 히스토그램 설정 (Data + Color Index)
   SetIndexBuffer(0, buffMomHist,  INDICATOR_DATA);
   SetIndexBuffer(1, buffMomColor, INDICATOR_COLOR_INDEX);

   // 스퀴즈 점 설정 (Data + Color Index)
   SetIndexBuffer(2, buffSqzDots,  INDICATOR_DATA);
   SetIndexBuffer(3, buffSqzColor, INDICATOR_COLOR_INDEX);

   // 계산용 내부 버퍼
   SetIndexBuffer(4, buffMomSrc,    INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, buffMomLinReg, INDICATOR_CALCULATIONS);

   // 점 모양 설정 (0선 고정)
   PlotIndexSetInteger(1, PLOT_ARROW, 158);

   // 핸들 생성
   handleSMA    = iMA(_Symbol, _Period, InpPeriod, 0, MODE_SMA, PRICE_CLOSE);
   handleStdDev = iStdDev(_Symbol, _Period, InpPeriod, 0, MODE_SMA, PRICE_CLOSE);
   handleATR    = iATR(_Symbol, _Period, InpPeriod);

   if (handleSMA == INVALID_HANDLE || handleStdDev == INVALID_HANDLE || handleATR == INVALID_HANDLE) return(INIT_FAILED);

   // IndicatorSetString(INDICATOR_SHORTNAME, "TTM Squeeze (Color Index)");
   // IndicatorSetString(INDICATOR_SHORTNAME, "Squeeze Momentum (Built-in)");
   // IndicatorSetString(INDICATOR_SHORTNAME, CharToString(0x200B));
   IndicatorSetString(INDICATOR_SHORTNAME, " ");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   // 데이터가 충분한지 확인
   if (rates_total < InpPeriod + 1) return(0);

   // 데이터 복사용 임시 배열 (동적 배열)
   double arrSMA[], arrDev[], arrATR[];

   // 최신 데이터까지 복사 (ArraySetAsSeries 미사용 시 인덱스 0은 가장 과거 봉)
   if (CopyBuffer(   handleSMA, 0, 0, rates_total, arrSMA) <= 0) return 0;
   if (CopyBuffer(handleStdDev, 0, 0, rates_total, arrDev) <= 0) return 0;
   if (CopyBuffer(   handleATR, 0, 0, rates_total, arrATR) <= 0) return 0;

   int start = (prev_calculated > 0) ? prev_calculated - 1 : InpPeriod;

   for (int i = start; i < rates_total; i++)
   {
      // 1. 스퀴즈 판별 (BB폭 < KC폭)
      double dev = arrDev[i] * InpBBMult;
      double atr = arrATR[i] * InpKCMult;
      bool sqzOn = (dev < atr);

      buffSqzDots[i] = 0; // 항상 0선에 표시
      buffSqzColor[i] = sqzOn ? 0 : 1; // 0:Red, 1:Lime

      // 2. 모멘텀 소스 계산
      int highestIdx = ArrayMaximum(high, i - InpPeriod + 1, InpPeriod);
      int lowestIdx  = ArrayMinimum( low, i - InpPeriod + 1, InpPeriod);
      if (highestIdx < 0 || lowestIdx < 0) continue;

      double avg = (high[highestIdx] + low[lowestIdx]) / 2.0;
      buffMomSrc[i] = close[i] - ((avg + arrSMA[i]) / 2.0);

      // 3. 선형 회귀 적용 (Smoothing)
      buffMomLinReg[i] = CalculateLinReg(buffMomSrc, InpPeriod, i);
      // buffMomLinReg[i] = CalculateALMA(buffMomSrc, InpPeriod, i);

      // 4. 히스토그램 값 및 색상 인덱스 설정
      double current = buffMomLinReg[i];
      double prior   = (i > 0) ? buffMomLinReg[i-1] : 0;

      buffMomHist[i] = current;

      if (current > 0)
         buffMomColor[i] = (current > prior) ? 0 : 1; // 0:연두(상승가속), 1:초록(상승감속)
      else
         buffMomColor[i] = (current < prior) ? 2 : 3; // 2:빨강(하락가속), 3:자주(하락감속)
   }

   return (rates_total);
}

//--- 선형 회귀 계산 함수 ---
double CalculateLinReg(const double &src[], int p, int pos, int forecast = 1)
{
   if (pos < p - 1) return 0; // 데이터 부족 시 제외

   double sumX  = 0;     // X의 합 (시간)
   double sumY  = 0;     // Y의 합 (데이터 값)
   double sumX2 = 0;     // X제곱의 합
   double sumXY = 0;     // X*Y의 합

   // n(데이터 개수) = p
   // X축을 1부터 p까지로 설정하여 계산의 안정성 확보
   for (int i = 0; i < p; i++)
   {
      double y = src[pos - (p - 1) + i];
      double x = i + 1; // 1, 2, 3, ..., p (과거 -> 현재 순서)

      sumX  += x;
      sumY  += y;
      sumX2 += x * x;
      sumXY += x * y;
   }

   // 선형 회귀 공식: y = a + bx
   // 기울기 b = (n*sumXY - sumX*sumY) / (n*sumX2 - sumX^2)
   double denominator = (p * sumX2 - sumX * sumX);
   if (MathAbs(denominator) < 1e-10) return 0; // 0으로 나누기 방지

   double b = (p * sumXY - sumX * sumY) / denominator;
   double a = (sumY - b * sumX) / p;

   // 우리가 필요한 것은 '현재 시점(x = p)'에서의 예측값
   // return a + b * p;
   return a + b * (p + forecast); // 다음 봉 예측값 (후행성 제거 버전)
}

/*
설정에 필요한 3요소
Window Size (기간): 일반 이평선의 '길이'와 같습니다. (기본값: 9)
Offset (오프셋): 지표의 반응 속도를 결정합니다. 1에 가까울수록 최근 가격에 밀착(민감)해지고, 0에 가까울수록 부드러워집니다. (기본값: 0.85)
Sigma (시그마): 가중치 분산 정도를 정합니다. 수치가 클수록 선이 더 부드러워집니다. (기본값: 6)
*/
double CalculateALMA(const double &src[], int window, int pos, double offset = 0.85, double sigma = 6.0)
{
   if (pos < window - 1) return 0; // 데이터 부족 방지

   double m = offset * (window - 1);    // 가중치 중심점 (Offset)
   double s = window / sigma;           // 가우시안 분포의 폭 (Sigma)

   double sumWeights = 0;
   double sumValues = 0;

   for (int i = 0; i < window; i++)
   {
      // 현재(pos)에서 과거로 갈수록 i가 커짐 (0 = 현재, window-1 = 가장 과거)
      // ALMA 공식: exp(-(i - m)^2 / (2 * s^2))
      double weight = MathExp(-MathPow(i - m, 2) / (2 * MathPow(s, 2)));

      sumValues  += src[pos - i] * weight;
      sumWeights += weight;
   }

   if (sumWeights > 0)
      return sumValues / sumWeights;
   else
      return 0;
}
