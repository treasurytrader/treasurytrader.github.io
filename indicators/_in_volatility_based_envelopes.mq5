#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2

#property indicator_label1  "VBE Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_label2  "VBE Dn"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRoyalBlue

//--- buffers
double up[], dn[], chng_rt[], rawVBE_up[], rawVBE_dn[];

//--- 구조체 정의 (6개 주기 데이터 보관용)
struct Array6 { double v[6]; };
Array6 VBE_up[], VBE_dn[], up_chg[], dn_chg[];

//--- 설정 변수
int periods[6] = {21, 17, 13, 9, 5, 2};

int OnInit() {
   SetIndexBuffer(0, up, INDICATOR_DATA);
   SetIndexBuffer(1, dn, INDICATOR_DATA);
   SetIndexBuffer(2, rawVBE_up, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, rawVBE_dn, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, chng_rt, INDICATOR_CALCULATIONS);

   // 논문 로직 핵심: 역방향 인덱스 설정
   ArraySetAsSeries(up, true);
   ArraySetAsSeries(dn, true);
   ArraySetAsSeries(rawVBE_up, true);
   ArraySetAsSeries(rawVBE_dn, true);
   ArraySetAsSeries(chng_rt, true);

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {

   if(rates_total < 64) return 0;

   // 구조체 배열 크기 및 시계열 설정
   if(ArraySize(up_chg) != rates_total) {
      ArrayResize(VBE_up, rates_total); ArrayResize(VBE_dn, rates_total);
      ArrayResize(up_chg, rates_total); ArrayResize(dn_chg, rates_total);
      ArraySetAsSeries(VBE_up, true);   ArraySetAsSeries(VBE_dn, true);
      ArraySetAsSeries(up_chg, true);   ArraySetAsSeries(dn_chg, true);
   }

   // 입력 배열 시계열 설정
   ArraySetAsSeries(close, true);

   int limit = rates_total - (prev_calculated ? prev_calculated : 64);
   if(limit < 0) limit = 0;

   for(int i = limit; i >= 0; i--) {
      if(i + 1 >= rates_total) continue;

      // 1. 가격 변동률 계산
      chng_rt[i] = (close[i+1] != 0) ? (close[i] / close[i+1] - 1.0) : 0;

      // 2. 표준편차 및 원시 VBE (21일 주기)
      double avg_chg = SMA_Custom(chng_rt, periods[0], i, rates_total);
      double sum_sq = 0;
      for(int j = 0; j < periods[0]; j++) {
         if(i + j < rates_total) sum_sq += MathPow(chng_rt[i+j], 2);
      }
      double dev = MathSqrt(sum_sq / periods[0]);

      rawVBE_up[i] = close[i] * (1.0 + (avg_chg + (dev * 2.0)));
      rawVBE_dn[i] = close[i] * (1.0 + (avg_chg - (dev * 2.0)));

      // 3. 6개 주기에 대한 가중 이동평균(LWMA) 및 변화율 산출
      for(int j = 0; j < 6; j++) {
         VBE_up[i].v[j] = LWMA_Custom(rawVBE_up, periods[j], i, rates_total);
         VBE_dn[i].v[j] = LWMA_Custom(rawVBE_dn, periods[j], i, rates_total);

         if(i + 1 < rates_total) {
            if(VBE_up[i+1].v[j] > 0) up_chg[i].v[j] = (VBE_up[i].v[j] - VBE_up[i+1].v[j]) / VBE_up[i+1].v[j];
            if(VBE_dn[i+1].v[j] > 0) dn_chg[i].v[j] = (VBE_dn[i].v[j] - VBE_dn[i+1].v[j]) / VBE_dn[i+1].v[j];
         }
      }

      // 4. 상관관계 기반 예측치 도출
      double f_up[6], f_dn[6];
      f_up[0] = VBE_up[i].v[0];
      f_dn[0] = VBE_dn[i].v[0];

      for(int j = 1; j < 6; j++) {
         double u_cor = Correlation_Custom(up_chg, 63, i, j, rates_total);
         double d_cor = Correlation_Custom(dn_chg, 63, i, j, rates_total);
         f_up[j] = f_up[j-1] * (1.0 + (up_chg[i].v[j] * u_cor));
         f_dn[j] = f_dn[j-1] * (1.0 + (dn_chg[i].v[j] * d_cor));
      }

      // 5. 미래 방향으로 예측치 투영 (시차 제거 시각화)
      for(int j = 5; j >= 0; j--) {
         if(i + j < rates_total) {
            up[i + j] = f_up[5 - j];
            dn[i + j] = f_dn[5 - j];
         }
      }
   }
   return(rates_total);
}

//--- 고정 로직 헬퍼 함수들 ---
double Correlation_Custom(const Array6 &ind[], int len, int bar, int k, int total) {
   int c1 = 0, c2 = 0;
   for(int i = 0; i < len && (bar+i+1) < total; i++) {
      if((ind[bar+i+1].v[0] <= ind[bar+i].v[0] && ind[bar+i+1].v[k] <= ind[bar+i].v[k]) ||
         (ind[bar+i+1].v[0] >  ind[bar+i].v[0] && ind[bar+i+1].v[k] >  ind[bar+i].v[k])) c1++;
      else c2++;
   }
   return (c1 + c2 > 0) ? (double)(c1 - c2) / (c1 + c2) : 0;
}

double SMA_Custom(const double &arr[], int per, int bar, int total) {
   double s = 0; int cnt = 0;
   for(int i = 0; i < per && (bar+i) < total; i++) { s += arr[bar+i]; cnt++; }
   return (cnt > 0) ? s / cnt : 0;
}

double LWMA_Custom(const double &arr[], int per, int bar, int total) {
   double s = 0, w_sum = 0;
   for(int i = 0; i < per && (bar+i) < total; i++) {
      double w = per - i;
      s += arr[bar+i] * w; w_sum += w;
   }
   return (w_sum > 0) ? s / w_sum : 0;
}
