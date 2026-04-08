# 10. 이미지 유사도 검색 PoC (Image Similarity Search)

## 📋 개요

리테일 상품 이미지를 입력하면 **시각적으로 유사한 상품**을 찾아주는 PoC입니다.  
구글 이미지 검색, 네이버 이미지 검색과 같은 기능을 Azure AI Search로 구현합니다.

## 🎯 학습 목표

| 항목 | 설명 |
|------|------|
| **이미지 벡터화** | Azure AI Vision Florence로 이미지를 직접 1024D 임베딩 |
| **GPT 피쳐 추출** | GPT-5.2 Structured Output으로 이미지에서 9개 구조화 피쳐 자동 추출 |
| **듀얼 텍스트 임베딩** | 같은 피쳐 텍스트를 Florence(1024D) + OpenAI(3072D) 두 모델로 임베딩 |
| **4-way 하이브리드 검색** | 이미지 벡터 + Florence 텍스트 벡터 + OpenAI 텍스트 벡터 + BM25 → RRF 통합 |
| **판단 근거 제공** | `structured_features` 피쳐 비교 테이블로 유사 이유를 항목별 설명 |

## 📂 노트북

| 순서 | 노트북 | 내용 |
|:---:|--------|------|
| 1 | [02-image_similarity_poc.ipynb](./02-image_similarity_poc.ipynb) | 독립 인덱스 생성 → 이미지/피쳐 벡터 업로드 → 4-way 하이브리드 유사 상품 검색 데모 |

## 🗄️ 인덱스 필드 구조 (`image-similarity-poc`)

| 필드 | 타입 | 차원 | 모델 | 용도 |
|------|------|------|------|------|
| `image_vector` | Vector | 1024D | Azure AI Vision Florence | 이미지 픽셀 직접 임베딩 (시각적 유사도) |
| `feature_text_vector` | Vector | 1024D | Azure AI Vision Florence | 피쳐 텍스트 임베딩 (시각-의미 크로스모달) |
| `feature_text_vector_3072` | Vector | 3072D | text-embedding-3-large | 피쳐 텍스트 임베딩 (텍스트 의미 유사도) |
| `structured_features` | Complex | - | GPT-5.2 Structured Output | 9개 구조화 피쳐 (매칭 근거) |

## 🔀 검색 전략 — 4-way 하이브리드

```
📸 신규 이미지
    ↓
    ├─ 경로 1: 이미지 → AI Vision → 1024D → image_vector 검색 (시각 유사도)
    ├─ 경로 2: 피쳐 텍스트 → AI Vision → 1024D → feature_text_vector 검색 (크로스모달)
    ├─ 경로 3: 피쳐 텍스트 → text-embedding-3-large → 3072D → feature_text_vector_3072 검색 (의미)
    └─ 경로 4: 피쳐 텍스트 → BM25 키워드 검색 (키워드 매칭)
    ↓
    RRF 통합 → 이미지 그리드 + 피쳐 비교 테이블
```

| 경로 | 입력 | 임베딩 모델 | 검색 필드 | 역할 |
|------|------|------------|----------|------|
| 경로 1 | 이미지 픽셀 | Azure AI Vision Florence | `image_vector` | 시각적 유사도 — 색상, 형태, 디자인 |
| 경로 2 | 피쳐 텍스트 | Azure AI Vision Florence | `feature_text_vector` | 시각-의미 크로스모달 (이미지↔텍스트 같은 공간) |
| 경로 3 | 피쳐 텍스트 | text-embedding-3-large | `feature_text_vector_3072` | 텍스트 의미 유사도 — 용도, 소재, 스타일 |
| 경로 4 | 피쳐 텍스트 | BM25 | `title`, `brand` 등 | 키워드 매칭 — 브랜드명, 제품 유형 |

## 📝 노트북 실행 흐름

| Step | 셀 | 내용 |
|------|-----|------|
| 1 | 환경 설정 | Azure AI Search, AI Vision, OpenAI 클라이언트 초기화 |
| 2 | 인덱스 생성 | `image-similarity-poc` 독립 인덱스 (메타 + 벡터 3종 + 피쳐) |
| 3 | 함수 정의 | 이미지 벡터화, 피쳐 추출, 텍스트 임베딩, 변환 함수 |
| 4 | API 테스트 | 샘플 1개로 4개 파이프라인 검증 |
| 5 | 샘플 처리 | 10개 제품으로 빠른 파이프라인 검증 |
| 6 | 전체 처리 | 247개 제품 전체 처리 (이미지벡터 + 피쳐추출 + 텍스트벡터 2종) |
| 7 | 인덱스 업로드 | 배치 업로드 + 검증 |
| 8 | 검색 데모 | 5개 시나리오 — 스포츠/유아동/패션/외부이미지(나이키)/외부이미지(운동화) |

## ⚠️ 사전 요구사항

- `.env` 파일에 아래 환경 변수 설정:
  - `SEARCH_ENDPOINT`, `SEARCH_ADMIN_KEY` — Azure AI Search
  - `AZURE_AI_VISION_ENDPOINT`, `AZURE_AI_VISION_KEY` — Azure AI Vision (Florence)
  - `AZURE_OPEN_AI_ENDPOINT`, `AZURE_OPEN_AI_KEY` — Azure OpenAI
  - `AZURE_OPENAI_CHAT_DEPLOYMENT` — GPT Vision 지원 모델 (GPT-5.2)
  - `AZURE_OPENAI_EMBEDDING_DEPLOYMENT` — text-embedding-3-large
  - `AZURE_OPENAI_EMBEDDING_API_VERSION`
- `00-data/sample_data.csv` 데이터 파일

## 🛒 리테일 시나리오별 검색 품질

| 시나리오 | 입력 예시 | 예상 정확도 | 핵심 경로 |
|---------|----------|:---:|----------|
| 카탈로그 이미지 | 쇼핑몰 상세 이미지 | ★★★★★ | 4개 경로 모두 |
| 모델 착용 사진 | 패션 룩북, 착용샷 | ★★★★☆ | 경로 2~4 우세 |
| 매장/거리 촬영 | 진열대, 거리 사진 | ★★★☆☆ | 경로 2~4 |
| 복수 상품 사진 | 코디 사진, 세트 | ★★☆☆☆ | 경로 2~4 (부분적) |
| 경쟁사 이미지 | 타사 웹사이트 | ★★★★★ | 4개 경로 모두 |
| SNS 이미지 | 인스타그램, 필터 적용 | ★★★☆☆ | 경로 2~4 |
