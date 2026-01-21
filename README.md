# Azure AI Search 핸즈온 워크샵

Azure AI Search의 검색 기술을 단계별로 직접 구현해보는 실습 워크샵입니다.

## 이 워크샵에서 배우는 것

| 모듈 | 핵심 기술 | 구현 내용 |
|------|----------|----------|
| 02-keyword_search | BM25, OData 필터, Facet | 인덱스 스키마 정의, `ko.lucene` 한국어 분석기, 필터/정렬/집계 |
| 03-vector_search | HNSW, KNN, 임베딩 | 벡터 필드 추가, `text-embedding-3-small`로 1536차원 벡터 생성 |
| 04-hybrid_search | RRF (Reciprocal Rank Fusion) | 키워드+벡터 결합, 점수 계산 원리 이해 |
| 05-scoring_profile | TextWeights, Magnitude, Tag 함수 | 필드 가중치, 가격 기반 부스팅, 브랜드 우선순위 |
| 06-re_ranking | Semantic L2 모델, Captions/Answers | 하이브리드 결과 재정렬, 답변 추출 |
| 07-enriched_dataset | GPT Vision | 이미지 분석 → 텍스트 증강 → 벡터 재생성 |
| 08-skillsets (개념) | Indexer, Skillset, Knowledge Store | OCR/Entity Recognition 등 Built-in Skills, Custom Skills, 실무 시나리오 5가지 |

## 기술 스택

```
azure-search-documents >= 11.4.0
openai >= 1.12.0
python-dotenv
pandas, numpy
```

## 사전 준비

### Azure 리소스
- **Azure AI Search**: Basic 이상 (Semantic ranker 사용 시)
- **Azure OpenAI/AI Foundry**: `text-embedding-3-small`, `gpt-4o-mini` 배포

### 환경 설정

```powershell
# 가상환경 생성 및 활성화
python -m venv .venv
.venv\Scripts\activate

# 패키지 설치
pip install -r requirements.txt

# 환경변수 설정
copy .env.sample .env
# .env 파일에 실제 값 입력
```

**.env 필수 항목:**
```
SEARCH_ENDPOINT=https://<your-service>.search.windows.net
SEARCH_ADMIN_KEY=<admin-key>
SEARCH_INDEX_NAME=products-index
FOUNDRY_PROJECT_ENDPOINT=https://<your-endpoint>.openai.azure.com
FOUNDRY_PROJECT_KEY=<api-key>
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=text-embedding-3-small
AZURE_OPENAI_CHAT_DEPLOYMENT=gpt-4o-mini
AZURE_OPENAI_API_VERSION=2024-06-01
```

## 샘플 데이터

`00-data/sample_data.csv` - 한국어 이커머스 상품 247건

| 필드 | 타입 | 용도 |
|------|------|------|
| product_id | string | 문서 키 |
| title | string | 검색 대상 (SearchableField) |
| brand | string | 필터/패싯 |
| category | string | 필터/패싯 |
| price | int | Magnitude 함수용 |
| review | string | 검색 대상, Semantic 분석 |
| image_link | string | Vision 분석용 |

## 실습 순서

### Phase 1: 기본 검색 파이프라인

```
01-setup/test_connection.ipynb     → 리소스 연결 확인
02-keyword_search/01-create_index  → 인덱스 스키마 정의
02-keyword_search/02-upload_data   → 문서 업로드
02-keyword_search/03-keyword_search → BM25, 필터, 패싯
```

**이 단계에서 익히는 API:**
- `SearchIndexClient.create_or_update_index()`
- `SearchClient.upload_documents()`
- `SearchClient.search(search_text, filter, facets, order_by)`

### Phase 2: 벡터 검색

```
03-vector_search/01-update_index   → 벡터 필드, HNSW 프로필 추가
03-vector_search/02-upload_vectors → 임베딩 생성 및 업로드
03-vector_search/03-vector_search  → 벡터 검색 실행
```

**이 단계에서 익히는 개념:**
- HNSW (Hierarchical Navigable Small World) vs Exhaustive KNN
- `VectorizedQuery(vector, k_nearest_neighbors, fields)`
- 임베딩 차원과 유사도 메트릭 (cosine)

### Phase 3: 하이브리드 검색

```
04-hybrid_search/01-hybrid_search  → 키워드 + 벡터 결합
```

**핵심 코드:**
```python
results = search_client.search(
    search_text="가벼운 운동화",
    vector_queries=[VectorizedQuery(vector=embedding, k_nearest_neighbors=10, fields="content_vector")]
)
# RRF 점수 = Σ(1 / (k + rank)), k=60
```

### Phase 4: 검색 품질 튜닝

```
05-scoring_profile/01-scoring_profile → 비즈니스 로직 반영
06-re_ranking/01-semantic_reranking   → L2 모델로 재정렬
```

**Scoring Profile 예시:**
```python
ScoringProfile(
    name="lowPriceFirst",
    functions=[
        MagnitudeScoringFunction(
            field_name="price",
            boost=2,
            parameters=MagnitudeScoringParameters(
                boosting_range_start=0,
                boosting_range_end=50000,
                should_boost_beyond_range_by_constant=False
            )
        )
    ]
)
```

**Semantic Re-ranking:**
```python
results = search_client.search(
    search_text="따뜻한 겨울 자켓",
    query_type=QueryType.SEMANTIC,
    semantic_configuration_name="my-semantic-config",
    query_caption=QueryCaptionType.EXTRACTIVE,
    query_answer=QueryAnswerType.EXTRACTIVE
)
```

### Phase 5: 데이터 증강

```
07-enriched_dataset/01-enrich_with_vision → GPT Vision으로 이미지 분석
```

**파이프라인:**
```
이미지 URL → GPT Vision 분석 → 텍스트 특징 추출 → content_text에 병합 → 벡터 재생성 → 인덱스 업데이트
```

### 개념 학습 (실습 없음)

```
08-skillsets_aienrichment/README.md → Indexer + Skillset 개념
```

- OCR, Entity Recognition, Key Phrase Extraction 등
- Knowledge Store 활용
- 실제 구현 시 별도 Azure AI Services 리소스 필요

## 검색 방식별 특성 비교

| 방식 | 장점 | 단점 | 적합한 케이스 |
|------|------|------|--------------|
| Keyword (BM25) | 정확한 용어 매칭 | 동의어, 의미 파악 불가 | 제품코드, 브랜드명 검색 |
| Vector | 의미 기반 유사도 | 정확한 키워드 놓칠 수 있음 | 자연어 질의, 유사 상품 |
| Hybrid (RRF) | 두 방식의 장점 결합 | 단순 순위 결합 | 일반적인 검색 |
| Hybrid + Semantic | 의미 기반 재정렬 | 추가 비용/지연 | 높은 품질 요구 시 |

## 비용 고려사항

- Azure AI Search Basic: 약 $73/월
- Semantic Ranker: 쿼리당 추가 비용 (1,000 쿼리당 약 $1)
- Azure OpenAI 임베딩: 토큰 기반 과금
- GPT Vision: 이미지당 과금

## 폴더 구조

```
├── 00-data/sample_data.csv
├── 01-setup/test_connection.ipynb
├── 02-keyword_search/
│   ├── 01-create_index.ipynb
│   ├── 02-upload_data.ipynb
│   └── 03-keyword_search.ipynb
├── 03-vector_search/
│   ├── 01-update_index.ipynb
│   ├── 02-upload_vectors.ipynb
│   └── 03-vector_search.ipynb
├── 04-hybrid_search/01-hybrid_search.ipynb
├── 05-scoring_profile/01-scoring_profile.ipynb
├── 06-re_ranking/
│   ├── 01-semantic_reranking.ipynb
│   └── 02-semantic_preview_features.ipynb
├── 07-enriched_dataset/01-enrich_with_vision.ipynb
├── 08-skillsets_aienrichment/README.md
├── requirements.txt
└── .env.sample
```

## 참고 문서

- [Azure AI Search REST API](https://learn.microsoft.com/rest/api/searchservice/)
- [azure-search-documents Python SDK](https://learn.microsoft.com/python/api/overview/azure/search-documents-readme)
- [Vector Search 개요](https://learn.microsoft.com/azure/search/vector-search-overview)
- [Semantic Ranking](https://learn.microsoft.com/azure/search/semantic-search-overview)
