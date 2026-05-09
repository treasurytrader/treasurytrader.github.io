---
layout: default
---

# EMA <-> SMMA 비교

---

## 1. 수학적 일치성 (Equivalence)

* EMA (Exponential Moving Average) 평활화 계수 : 2/(n+1)
* SMMA (Smoothed Moving Average) 평활화 계수 : 1/n

| 지표 | 계산식 (α) | 결과 |
| :--- | :--- | :--- |
| EMA (19) | 2/(19+1) | 0.1 |
| SMMA (10) | 1/10 | 0.1 |

SMMA(10)를 사용하는 것은 EMA(19)를 사용하는 것과 같다.

---

## 2. 변환식 (Conversion Formula)

### SMMA를 EMA로 변환
> **EMA 기간 = (SMMA 기간 × 2) - 1**
* SMMA 10일 -> EMA 19일
* SMMA 50일 -> EMA 99일

### EMA를 SMMA로 변환
> **SMMA 기간 = (EMA 기간 + 1) / 2**
* EMA 21일 -> SMMA 11일
* EMA 100일 -> SMMA 50.5일 (약 50일)

---

## 3. 실전 적용

수학적으로는 정확히 (x2) - 1이지만,<br />
이동평균선 기간이 길어질수록 -1의 영향력은 미미해지기 때문에<br />
실전에서는 EMA 기간을 그냥 2배로 설정하는게 편하다.

* SMMA 50 -> EMA 100 (거의 일치)
* SMMA 100 -> EMA 200 (거의 일치)

---

## 4. 코드 구현 효율성

1. EMA (깔끔한 한 줄 계산)
```
current_ema = (alpha * current_price) + ((1 - alpha) * prev_ema)
```

2. SMMA (루프가 필요한 구조)
```
if first_time:
    sum_price = 0
    for i in range(n):
        sum_price += prices[i]
    prev_smma = sum_price / n
else:
    current_smma = (prev_smma * (n - 1) + current_price) / n
```
* 효율성 : EMA가 압도적으로 유리하다. (연산량 적음, 메모리 효율 높음)
* 대중성 : EMA는 어디에나 있다.

---

## 5. 트레이딩 인사이트: 지표의 환상

많은 초보들이 SMMA를 EMA와는 다른 특별한 알고리즘으로 오해한다.<br />
하지만 수학적으로 분석해보면 SMMA는 단지 EMA의 가중치를 절반으로 낮춘 것에 불과하다.<br />

중요한 것은 '어떤 지표를 쓰느냐'가 아니라,<br />
'해당 지표 특성을 이해하고 자신의 매매에 맞게 조절할 줄 아느냐'이다.<br />

본질을 알면 도구에 휘둘리지 않는다.

---
