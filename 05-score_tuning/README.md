# 5️⃣ 검색 가중치 & 스코어 튜닝

## 🎯 이 폴더에서 얻어갈 수 있는 것

이 실습을 완료하면 다음을 할 수 있게 됩니다:

| 학습 항목 | 설명 |
|----------|------|
| **⚖️ 벡터 검색 가중치** | 멀티 벡터 필드 간 비중을 조절하는 방법을 익힙니다 |
| **🔀 하이브리드 검색 가중치** | 키워드 vs 벡터 비중을 weight로 조절하는 방법을 배웁니다 |
| **📊 Scoring Profile** | BM25 키워드 검색에 비즈니스 로직을 적용하는 방법을 배웁니다 |
| **📈 Magnitude 함수 활용** | 숫자 필드(가격)를 기준으로 점수를 부스팅하는 방법을 구현합니다 |
| **🏷️ Tag 함수 활용** | 특정 값(프리미엄 브랜드)과 매칭 시 점수를 높이는 방법을 배웁니다 |
| **🔄 가중치 비교 실습** | 동일 쿼리에서 가중치 변경에 따른 순위 변화를 비교 분석합니다 |

### 📓 노트북 학습 순서

| 순서 | 노트북 | 핵심 내용 |
|------|--------|----------|
| 1️⃣ | [01-scoring_profile.ipynb](./01-scoring_profile.ipynb) | 벡터 가중치, 하이브리드 가중치, Scoring Profile (TextWeights, Magnitude, Tag) |

### 🔧 실습 구조

이 실습은 **기존 인덱스와 데이터를 재사용**합니다:

```
01-setup → 02-keyword_search → 03-vector_search → 04-hybrid_search
                                                          ↓
                                                   05-score_tuning
                                                   (가중치 & 스코어 튜닝)
```

- ✅ 새 인덱스 생성 불필요 (기존 products-index 사용)
- ✅ 데이터 재업로드 불필요 (이미 업로드된 데이터 활용)
- ✅ Scoring Profile만 추가/테스트

---

## 💡 Scoring Profile이란?

### 정의

**Scoring Profile**은 Azure AI Search에서 검색 점수(@search.score)에 **비즈니스 로직**을 추가로 적용하는 기능입니다.

기본 BM25 점수 + **사용자 정의 부스팅** = 최종 검색 점수

### 왜 필요한가?

| 상황 | 기본 검색 | Scoring Profile 적용 |
|------|----------|---------------------|
| "선물" 검색 | 텍스트 매칭 순 | ✅ 저가 상품 우선 노출 |
| "자켓" 검색 | BM25 점수 순 | ✅ 프리미엄 브랜드 우선 노출 |
| "유아동" 검색 | 관련성 순 | ✅ 주력 브랜드(압소바, 밍크뮤) 우선 노출 |

---

## 📐 Scoring Profile 구성 요소

### 1️⃣ 필드 가중치 (Field Weights)

특정 필드에서 검색어가 매칭될 때 점수를 높입니다.

```python
# title 필드에서 매칭 시 2배, brand 필드에서 매칭 시 1.5배
"weights": {
    "title": 2.0,
    "brand": 1.5
}
```

### 2️⃣ Magnitude 함수

**숫자 필드** 값에 따라 점수를 부스팅합니다.

| 파라미터 | 설명 |
|----------|------|
| `magnitude` | 숫자 범위 기반 부스팅 |
| `boostingRangeStart` | 부스팅 시작값 |
| `boostingRangeEnd` | 부스팅 종료값 |
| `constantBoostBeyondRange` | 범위 밖 값 처리 방식 |

**예시: 저가 상품 우선**
- 가격 0원 ~ 50,000원: 최대 부스팅
- 가격 50,000원 이상: 부스팅 감소

### 3️⃣ Tag 함수

**특정 값과 매칭**될 때 점수를 부스팅합니다.

| 파라미터 | 설명 |
|----------|------|
| `tagsParameter` | 부스팅할 태그 값들 |
| `fieldName` | 태그를 적용할 필드 |

**예시: 프리미엄 브랜드 우선**
- 노스페이스, 라코스테, 앤더슨벨 브랜드 매칭 시 부스팅

---

## 🛒 실습에서 정의하는 5가지 Scoring Profile

| 프로파일명 | 기능 | 적용 예시 |
|-----------|------|----------|
| **titleBoost** | 필드 가중치 | title 3배, brand 2배 → 상품명 매칭 우선 |
| **lowPriceFirst** | Magnitude (저가) | 0~10만원 높은 부스팅 → 가성비 상품 추천 |
| **highPriceFirst** | Magnitude (고가) | 10~50만원 높은 부스팅 → 프리미엄 상품 강조 |
| **premiumBrandFirst** | Tag | 노스페이스, 라코스테 등 10배 부스팅 |
| **bestValue** | 복합 | 필드 가중치 + 저가 우선 (2차 함수) |

---

## 📊 실습 시나리오 (노트북 내용)

### 비교 1: 필드 가중치 효과
- 검색어: "선물"
- 기본 vs titleBoost 점수 변화 분석

### 비교 2: 가격 기반 부스팅
- 검색어: "자켓"
- lowPriceFirst vs highPriceFirst 가격대 순서 비교

### 비교 3: 프리미엄 브랜드 부스팅
- 검색어: "자켓"
- Tag 함수로 특정 브랜드 우선 노출

### 비교 4: 복합 프로파일
- 검색어: "유아용품 선물"
- bestValue 프로파일의 복합 효과 분석

### 실무 시나리오
1. 유아동 카테고리 + 가성비 (lowPriceFirst)
2. 스포츠 카테고리 + 프리미엄 브랜드 (premiumBrandFirst)

---

## 📊 현재 데이터셋 기준 적용 가능한 필드

| 필드 | 타입 | Scoring Profile 적용 |
|------|------|---------------------|
| `title` | String | ✅ 필드 가중치 |
| `brand` | String | ✅ 필드 가중치, Tag 함수 |
| `category` | String | ✅ Tag 함수 |
| `normal_price` | Int32 | ✅ Magnitude 함수 |

> **참고**: Freshness(날짜 기반) 및 Distance(위치 기반) 함수는 현재 데이터셋에 해당 필드가 없어 다루지 않습니다.

---

## ⚠️ 주의사항

### Scoring Profile 제한 사항

1. **nonvector 필드에만 적용**: 벡터 유사도 점수 자체에는 영향 없음
2. **하이브리드 검색**: 키워드(BM25) 서브쿼리의 순위에 영향 → RRF 통합 결과에 간접 반영
3. **필터와 별개**: 필터는 결과를 제외, Scoring Profile은 순위만 조정
4. **Functions 필드 조건**: Magnitude, Tag 등 함수에 사용하는 필드는 반드시 `filterable`로 설정

### Best Practices

- 프로파일은 **인덱스 업데이트 필요**: `create_or_update_index()`로 기존 인덱스에 추가
- 여러 프로파일을 정의하고 **쿼리 시점에 선택** 가능
- 부스팅 값은 테스트를 통해 최적값 찾기 권장
- **중복 체크**: 기존 프로파일 이름과 충돌하지 않도록 주의

---

## ✅ 체크리스트

Scoring Profile 실습 완료 확인:

- [ ] 기존 인덱스 확인 및 Scoring Profile 5개 추가
- [ ] 필드 가중치 효과 비교 (titleBoost)
- [ ] 가격 기반 부스팅 비교 (low vs high)
- [ ] Tag 함수로 프리미엄 브랜드 부스팅
- [ ] 복합 프로파일 (bestValue) 효과 분석
- [ ] Interpolation 방식별 부스팅 패턴 이해
- [ ] 카테고리별 맞춤 검색 실습 (2가지)

---

## 🚀 다음 단계

Scoring Profile을 마스터한 후:

1. **[06-re_ranking](../06-re_ranking/)** - Semantic Ranker로 AI 기반 재순위화
2. **[07-enriched_dataset](../07-enriched_dataset/)** - AI Skills로 데이터 강화

---

## 📖 참고 자료

- [Azure AI Search Scoring Profiles](https://learn.microsoft.com/azure/search/index-add-scoring-profiles)
- [Scoring Profile Functions](https://learn.microsoft.com/azure/search/index-add-scoring-profiles#functions)
- [Scoring Profile Best Practices](https://learn.microsoft.com/azure/search/index-add-scoring-profiles#best-practices)
