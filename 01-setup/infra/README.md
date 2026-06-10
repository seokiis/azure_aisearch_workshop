# (선택) IaC로 빠르게 배포하기

> ⚠️ 이 워크샵의 **메인 학습 경로는 상위 [README.md](../README.md)의 Azure Portal 가이드**입니다.
> 이 폴더는 강사 테스트, 재배포, 환경 초기화 등을 위한 **보조 수단**으로만 사용하세요.
> 포털에서 직접 만들어보는 과정은 각 리소스의 옵션을 이해하는 데 중요합니다.

## 무엇이 만들어지나요?

상위 README의 1~4단계와 동일한 리소스를 한 번에 생성합니다.

| 리소스 | 이름 패턴 | 비고 |
|---|---|---|
| Azure AI Search | `foundryiq-aisearch-<suffix>` | Basic SKU, Korea Central |
| Azure AI Foundry (AIServices) | `foundryiq-openai-dev-<suffix>` | East US (모델 가용성) |
| Foundry Project | `proj-default-<suffix>` | |
| 모델 배포 | `gpt-4.1-mini`, `text-embedding-3-large` | |

배포가 끝나면 리포 루트의 `.env` 파일이 자동으로 채워집니다.

## 사전 준비

- Azure CLI 로그인 및 구독 선택
  ```bash
  az login
  az account set --subscription "<your-subscription-id>"
  ```
- `jq` 설치 (`brew install jq` 또는 `apt install jq`)

## 사용법

```bash
cd 01-setup/infra
chmod +x deploy.sh

# suffix 만 넘기면 rg-aisearch-<suffix> 리소스 그룹이 자동 생성됨
./deploy.sh 260114-changjuahn

# 또는 리소스 그룹/리전을 직접 지정
./deploy.sh 260114-changjuahn rg-aisearch-260114-changjuahn koreacentral
```

배포 완료 후 [test_connection.ipynb](../test_connection.ipynb) 를 실행해 연결을 확인하세요.

## 정리 (리소스 삭제)

```bash
az group delete --name rg-aisearch-260114-changjuahn --yes --no-wait
```

## 파일 구성

- `main.bicep` — 리소스 정의 (리소스 그룹 스코프)
- `deploy.sh` — `az deployment group create` 실행 + `.env` 자동 생성
