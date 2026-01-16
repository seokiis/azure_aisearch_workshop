# 🔍 Azure AI Search & Foundry IQ 핸즈온 워크샵

> **"검색의 기초부터 Agentic RAG까지, 단계별로 마스터하는 Azure AI Search 완벽 가이드"**

Azure AI Search의 핵심 기능을 **실습 중심**으로 학습하고, 최신 **Foundry IQ(Agentic Retrieval)** 기술까지 경험하는 종합 워크샵입니다.

---

## 🎯 이 워크샵을 완료하면?

| 레벨 | 달성 목표 | 해당 폴더 |
|------|----------|----------|
| 🟢 **입문** | Azure AI Search 환경 구축 및 기본 키워드 검색 구현 | 01~02 |
| 🟡 **중급** | 벡터/하이브리드 검색으로 의미 기반 검색 구현 | 03~04 |
| 🟠 **고급** | Scoring Profile, Semantic Re-Ranking으로 검색 품질 최적화 | 05~06 |
| 🔴 **전문가** | AI 기반 데이터 증강 및 Agentic Retrieval 구현 | 07~09 |

---

## 🗺️ 학습 로드맵

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Azure AI Search 학습 여정                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   [01-setup]              [02-keyword]           [03-vector]                     │
│   환경 설정               키워드 검색             벡터 검색                        │
│   ─────────────────────────────────────────────────────────                      │
│   • Azure 리소스 생성      • 인덱스 스키마 설계    • 임베딩 모델 활용               │
│   • Python 환경 구축       • BM25 검색 이해       • HNSW 알고리즘                  │
│   • 연결 테스트           • 필터/정렬/Facet       • 의미 기반 검색                 │
│                                                                                  │
│                               ↓                                                  │
│                                                                                  │
│   [04-hybrid]             [05-scoring]           [06-re_ranking]                 │
│   하이브리드 검색          스코어링 프로파일       시맨틱 리랭킹                    │
│   ─────────────────────────────────────────────────────────                      │
│   • RRF 알고리즘 이해      • 비즈니스 로직 적용    • L2 Re-Ranking                 │
│   • 키워드+벡터 결합       • 필드 가중치          • Captions & Answers            │
│   • 가중치 최적화         • Magnitude/Tag 함수   • 쿼리 의도 이해                 │
│                                                                                  │
│                               ↓                                                  │
│                                                                                  │
│   [07-enriched]           [08-skillsets]         [09-foundryiq]                  │
│   데이터 증강              AI Skillsets           Agentic Retrieval              │
│   ─────────────────────────────────────────────────────────                      │
│   • GPT Vision 활용        • Built-in Skills      • Knowledge Base 구축          │
│   • 이미지 분석           • OCR, 엔티티 추출      • 쿼리 플래닝                   │
│   • 검색 품질 향상         • Knowledge Store      • Reasoning Effort             │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📂 폴더별 상세 안내

### 📦 [00-data](./00-data/) - 샘플 데이터셋

| 항목 | 내용 |
|------|------|
| **데이터** | 이커머스 상품 데이터 247개 (한국어) |
| **카테고리** | 유아동, 스포츠/레져, 패션, 뷰티 등 11개 |
| **브랜드** | 압소바, 노스페이스, 샤넬, 디올 등 다양한 브랜드 |
| **필드** | 상품명, 브랜드, 카테고리, 가격, 이미지 URL |

**💡 활용 포인트**: 실제 이커머스 검색 시나리오를 그대로 재현하여 학습 가능

---

### 🛠️ [01-setup](./01-setup/) - 환경 설정

> **⏱️ 소요 시간**: 30~40분

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| Azure AI Search 프로비저닝 | SKU별 차이점(Free/Basic/Standard) 이해 |
| Azure AI Foundry 프로젝트 구성 | GPT-4, Embedding 모델 배포 |
| Python 개발 환경 구축 | 가상환경, SDK 설치 |
| 연결 테스트 | .env 설정, API 연결 검증 |

**🎯 목표**: 모든 실습을 수행할 수 있는 환경 완성

---

### 🔤 [02-keyword_search](./02-keyword_search/) - 키워드 검색

> **⏱️ 소요 시간**: 40~50분

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| 인덱스 스키마 설계 | `SimpleField`, `SearchableField` 차이 이해 |
| 한국어 분석기 | `ko.lucene` 형태소 분석 동작 원리 |
| BM25 알고리즘 | `@search.score` 점수 계산 원리 |
| OData 필터 | `eq`, `le`, `ge`, `and`, `or` 문법 |
| Facet 집계 | 카테고리/브랜드별 결과 분포 분석 |

**🎯 목표**: 전통적인 텍스트 검색의 원리와 한계 파악

---

### 🧮 [03-vector_search](./03-vector_search/) - 벡터 검색

> **⏱️ 소요 시간**: 50~60분

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| 벡터 필드 추가 | 기존 인덱스에 벡터 컬럼 추가 |
| 임베딩 생성 | `text-embedding-3-small` API 활용 |
| HNSW vs KNN | 속도/정확도 트레이드오프 이해 |
| 의미 기반 검색 | 키워드 불일치 시에도 관련 결과 검색 |

**🎯 목표**: "가벼운 외출복" → 바람막이, 가디건 검색되는 원리 이해

---

### 🔀 [04-hybrid_search](./04-hybrid_search/) - 하이브리드 검색

> **⏱️ 소요 시간**: 40~50분

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| RRF 알고리즘 | Reciprocal Rank Fusion 수식 이해 |
| 키워드+벡터 결합 | 양쪽 장점을 살린 검색 구현 |
| 가중치 조절 | `vector_weight` 파라미터 최적화 |
| 10가지 실무 시나리오 | 브랜드+의미, 정확한 용어+자연어 등 |

**🎯 목표**: 프로덕션 환경에서 권장되는 하이브리드 검색 마스터

---

### ⚖️ [05-scoring_profile](./05-scoring_profile/) - 스코어링 프로파일

> **⏱️ 소요 시간**: 40~50분

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| 필드 가중치 | title 3배, brand 2배 등 가중치 설정 |
| Magnitude 함수 | 가격 기반 부스팅 (저가/고가 우선) |
| Tag 함수 | 프리미엄 브랜드 우선 노출 |
| 복합 프로파일 | 여러 함수 조합으로 비즈니스 로직 구현 |

**🎯 목표**: 검색 결과에 비즈니스 요구사항 반영하는 방법 습득

---

### 🎯 [06-re_ranking](./06-re_ranking/) - 시맨틱 리랭킹

> **⏱️ 소요 시간**: 40~50분

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| RRF의 한계 | 순위만 결합, 의미는 모르는 문제 |
| L2 Re-Ranking | 언어 모델로 쿼리-문서 의미 재평가 |
| Semantic Configuration | titleField, contentFields, keywordFields 설정 |
| Captions & Answers | 관련 문장 추출, 질문 답변 기능 |
| `@search.rerankerScore` | 의미적 관련성 점수 (0~4) 해석 |

**🎯 목표**: AI 기반 재순위화로 검색 정확도 극대화

---

### 🖼️ [07-enriched_dataset](./07-enriched_dataset/) - 데이터 증강

> **⏱️ 소요 시간**: 50~60분

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| GPT Vision 활용 | 이미지 → 텍스트 특징 추출 |
| 데이터 증강 파이프라인 | 색상, 소재, 사용 시나리오 자동 생성 |
| 임베딩 재생성 | 증강된 콘텐츠로 벡터 업데이트 |
| 검색 품질 향상 | "따뜻한 겨울 신발" 검색 가능해짐 |

**🎯 목표**: AI로 검색 불가능했던 쿼리를 검색 가능하게 만들기

---

### 🧠 [08-skillsets_aienrichment](./08-skillsets_aienrichment/) - AI Skillsets (개념 가이드)

> **📖 읽기 전용** - 실습 없이 개념 이해

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| AI Enrichment 정의 | 검색 불가능한 콘텐츠를 검색 가능하게 |
| Built-in Skills | OCR, 엔티티 인식, 감정 분석 등 |
| Custom Skills | Azure Function으로 비즈니스 로직 |
| Knowledge Store | 증강 데이터를 Storage에 보관 |
| 5가지 비즈니스 시나리오 | 법률문서, 이커머스, 고객피드백, 의료기록, 미디어 |

**🎯 목표**: 언제 Skillset을 사용해야 하는지 판단 기준 확립

---

### 🤖 [09-foundryiq](./09-foundryiq/) - Agentic Retrieval

> **⏱️ 소요 시간**: 60~70분 | **🔬 Preview 기능**

| 학습 내용 | 얻어갈 수 있는 것 |
|----------|-----------------|
| Knowledge Base 구축 | AI Search 인덱스를 지식 소스로 등록 |
| Agentic Retrieval | LLM이 쿼리를 분해하고 병렬 실행 |
| Reasoning Effort | minimal, low, medium 설정별 차이 |
| Query Rewriting | 복잡한 쿼리가 어떻게 분해되는지 확인 |
| Activity 분석 | 실행 계획, 토큰 사용량 분석 |

**🎯 목표**: 차세대 Agentic RAG 아키텍처 이해 및 구현

---

### 🚀 [10-deploy_demo](./10-deploy_demo/) - 데모 앱 배포

> **📝 준비 중**

AI Search 기반 웹 애플리케이션 배포 및 모니터링

---

## ⚡ 빠른 시작

```bash
# 1. 리포지토리 클론
git clone <repository-url>
cd AzureAISearch_FoundryIQ_HandsOn

# 2. 가상환경 생성 및 활성화
python -m venv .venv
.\.venv\Scripts\Activate.ps1  # Windows PowerShell

# 3. 필수 패키지 설치
pip install -r requirements.txt

# 4. 환경 변수 설정
cp .env.sample .env
# .env 파일 열어서 Azure 리소스 정보 입력

# 5. 연결 테스트
# 01-setup/test_connection.ipynb 실행
```

---

## 📋 필수 요구사항

### Azure 리소스

| 리소스 | 용도 | 권장 SKU |
|--------|------|----------|
| **Azure AI Search** | 검색 서비스 | Basic (실습용) |
| **Azure OpenAI / AI Foundry** | 임베딩, GPT 모델 | Standard |
| **Azure Storage** | Knowledge Store (선택) | Standard |

### 개발 환경

| 요구사항 | 버전 |
|----------|------|
| Python | 3.9 이상 |
| VS Code | 최신 권장 |
| Jupyter Extension | VS Code용 |

---

## 📊 학습 소요 시간

| 구분 | 폴더 | 예상 시간 |
|------|------|----------|
| **필수 기초** | 01~04 | 약 3시간 |
| **검색 최적화** | 05~06 | 약 1.5시간 |
| **고급 기능** | 07~09 | 약 3시간 |
| **전체 완료** | 01~09 | **약 7.5시간** |

> 💡 **Tip**: 01~04까지만 완료해도 프로덕션 수준의 검색 시스템 구축 가능!

---

## 🔗 참고 자료

### 공식 문서
- [Azure AI Search 문서](https://learn.microsoft.com/azure/search/)
- [Vector Search 가이드](https://learn.microsoft.com/azure/search/vector-search-overview)
- [Semantic Ranker](https://learn.microsoft.com/azure/search/semantic-search-overview)
- [Agentic Retrieval](https://learn.microsoft.com/azure/search/agentic-retrieval-overview)

### 관련 프로젝트
- [Ignite LAB511 - Agentic Knowledge Bases](https://github.com/microsoft/ignite25-LAB511-build-agentic-knowledge-bases-next-level-rag-with-azure-ai-search)
- [Azure AI Search RAG Notebooks](https://github.com/Azure-Samples/rag-with-azure-ai-search-notebooks)
- [Azure Search OpenAI Demo](https://github.com/Azure-Samples/azure-search-openai-demo)

---

## 🤝 기여하기

개선 사항이나 오류를 발견하시면 Issue를 등록하거나 Pull Request를 보내주세요.

---

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 제공됩니다.
