# 09 - Foundry IQ (Agentic Retrieval)

## 📖 개요

이 모듈에서는 **Azure AI Search의 Agentic Retrieval** 기능을 실습합니다. Agentic Retrieval은 복잡한 질의를 LLM을 활용하여 여러 개의 하위 쿼리로 분해하고, 병렬로 실행하여 최적의 검색 결과를 제공하는 고급 검색 파이프라인입니다.

## 🎯 학습 목표

1. **Knowledge Source** 생성 - AI Search 인덱스를 지식 소스로 등록
2. **Knowledge Base** 구성 - LLM 기반 쿼리 플래닝을 위한 지식 베이스 설정
3. **Reasoning Effort** 비교 - minimal, low, medium 설정에 따른 결과 차이 확인
4. **Query Rewriting** 이해 - 복잡한 쿼리가 어떻게 분해되는지 확인
5. **Activity 분석** - 쿼리 실행 계획 및 토큰 사용량 분석

## 📁 실습 파일 구성

| 파일 | 설명 |
|------|------|
| `01-setup_knowledge_base.ipynb` | Knowledge Source 및 Knowledge Base 생성 |
| `02-agentic_retrieval.ipynb` | Agentic Retrieval 실행 및 Reasoning Effort 비교 |
| `03-cleanup.ipynb` | 실습 리소스 정리 |

## 🔧 사전 요구사항

### Azure 리소스
- **Azure AI Search** (Basic 이상, Semantic Ranker 활성화 필요)
- **Azure OpenAI** 또는 **Microsoft Foundry** 프로젝트
  - Embedding 모델: `text-embedding-3-small` 또는 `text-embedding-ada-002`
  - Chat 모델: `gpt-4o`, `gpt-4.1`, `gpt-5` 시리즈 중 하나

### Python 패키지
```bash
pip install azure-search-documents==11.7.0b2 openai python-dotenv
```

### 환경 변수 (`.env` 파일)
```env
# Azure AI Search
SEARCH_ENDPOINT=https://your-search-service.search.windows.net
SEARCH_ADMIN_KEY=your-search-admin-key

# Azure OpenAI / Foundry
FOUNDRY_PROJECT_ENDPOINT=https://your-resource.openai.azure.com
FOUNDRY_PROJECT_KEY=your-api-key
AZURE_OPENAI_API_VERSION=2025-11-01-preview
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=text-embedding-3-small
AZURE_OPENAI_CHAT_DEPLOYMENT=gpt-4o
```

## ⚠️ 주의사항

1. **Preview 기능**: Agentic Retrieval은 현재 Public Preview 단계입니다.
2. **비용**: LLM 기반 쿼리 플래닝은 Azure OpenAI 토큰 비용이 발생합니다.
3. **지역 제한**: 일부 Azure 지역에서만 사용 가능합니다.
4. **Semantic Ranker 필수**: Agentic Retrieval은 Semantic Ranker가 활성화되어야 합니다.

## 📊 Reasoning Effort 설명

| Effort | 설명 | 사용 사례 |
|--------|------|----------|
| `minimal` | LLM 쿼리 플래닝 없음, 단순 하이브리드 검색 | 단순한 질의, 비용 절감 |
| `low` | 기본 쿼리 분해, 1-2개 하위 쿼리 | 일반적인 RAG 애플리케이션 |
| `medium` | 심층 쿼리 분해, 반복적 검색 | 복잡한 분석 질의 |

## 🔗 참고 자료

- [Agentic Retrieval Overview](https://learn.microsoft.com/en-us/azure/search/agentic-retrieval-overview)
- [Quickstart: Agentic Retrieval](https://learn.microsoft.com/en-us/azure/search/search-get-started-agentic-retrieval)
- [Create Knowledge Base](https://learn.microsoft.com/en-us/azure/search/agentic-retrieval-how-to-create-knowledge-base)
