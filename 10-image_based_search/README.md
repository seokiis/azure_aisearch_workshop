# 10. 이미지 & 멀티모달 검색 (Image & Multimodal Search)

## 📋 개요

이미지 벡터 인덱싱부터 멀티모달 검색 실험까지, **이미지 기반 상품 검색**의 전체 파이프라인을 실습합니다.

## 🎯 학습 목표

| 항목 | 설명 |
|------|------|
| **이미지 벡터화** | Azure AI Vision Florence로 이미지 직접 1024D 임베딩 |
| **크로스모달 검색** | 같은 Florence 공간에서 이미지↔텍스트 검색 |
| **멀티벡터 RRF** | 여러 벡터 필드를 동시 검색하고 RRF로 통합 |
| **A/B/C 실험** | 순수 이미지 vs 사용자 텍스트 vs GPT 자동분석 비교 |
| **2-Stage 검색** | 즉시 응답(이미지) + GPT 리랭킹 패턴 |

## 📂 노트북

| 순서 | 노트북 | 내용 |
|:---:|--------|------|
| 1 | [01-create_image_vectors.ipynb](./01-create_image_vectors.ipynb) | 인덱스에 `image_vector`, `mm_vision_text_vector`, `structured_features` 3개 필드 추가 & 데이터 업로드 |
| 2 | [01-image_based_search.ipynb](./01-image_based_search.ipynb) | GPT Vision 기반 이미지→텍스트→하이브리드 검색 (기본) |
| 3 | [01-image_based_search_v2.ipynb](./01-image_based_search_v2.ipynb) | 멀티모달 검색 v2 — A/B/C 서브모드, 듀얼 벡터, 2-Stage, Florence 공간 검증 |

## 🗄️ 벡터 필드 구조

| 필드 | 차원 | 모델 | 용도 |
|------|------|------|------|
| `image_vector` | 1024D | AI Vision Florence | 이미지 픽셀 직접 임베딩 |
| `mm_vision_text_vector` | 1024D | AI Vision Florence | 텍스트를 같은 공간에 임베딩 |
| `content_vector` | 3072D | text-embedding-3-large | 텍스트 의미 임베딩 |
| `structured_features` | Complex | GPT-5.2 | 9개 구조화 피처 (매칭 근거) |

## ⚠️ 사전 요구사항

- `02-keyword_search` ~ `07-enriched_dataset` 실습 완료 (인덱스 + 벡터 + enriched_content)
- `.env` 파일에 `AZURE_AI_VISION_ENDPOINT`, `AZURE_AI_VISION_KEY` 설정
- `.env` 파일에 `AZURE_OPENAI_CHAT_DEPLOYMENT` 설정 (GPT Vision 지원 모델)

## 📝 v2 검색 모드 요약

| 모드 | 쿼리 벡터 | 검색 필드 | BM25 |
|------|----------|----------|:---:|
| **이미지 (A)** | 이미지→1024D | `image_vector` | ✗ |
| **이미지 (B)** | 이미지→1024D + 텍스트→1024D | `image_vector` + `mm_vision_text_vector` | ✓ |
| **이미지 (C)** | 이미지→1024D + GPT텍스트→1024D | `image_vector` + `mm_vision_text_vector` | ✓ |
| **텍스트만** | 텍스트→1024D + 텍스트→3072D | `mm_vision_text_vector` + `content_vector` | ✓ |
