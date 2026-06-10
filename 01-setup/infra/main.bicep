// =====================================================================
// Azure AI Search Workshop - One-Click IaC
// 리소스 그룹 스코프에서 Azure AI Search + AI Foundry(AIServices) + 모델 2종을 배포합니다.
// =====================================================================
targetScope = 'resourceGroup'

@description('리소스 이름 접미사 (예: 260114-changjuahn). 영문 소문자/숫자/하이픈만 사용하세요.')
param suffix string

@description('Azure AI Search 리전')
param searchLocation string = 'koreacentral'

@description('Azure AI Foundry (AIServices) 리전. 모델 가용성에 따라 eastus / swedencentral 권장')
@allowed([
  'eastus'
  'eastus2'
  'swedencentral'
  'westus'
  'westus3'
])
param foundryLocation string = 'eastus'

@description('Azure AI Search SKU')
@allowed([
  'free'
  'basic'
  'standard'
])
param searchSku string = 'basic'

@description('Foundry 기본 프로젝트 이름')
param projectName string = 'proj-default-${suffix}'

@description('Chat 모델 배포 이름')
param chatDeploymentName string = 'gpt-4.1-mini'

@description('Chat 모델 버전 (Azure OpenAI에서 사용 가능한 버전)')
param chatModelVersion string = '2025-04-14'

@description('Embedding 모델 배포 이름')
param embeddingDeploymentName string = 'text-embedding-3-large'

@description('Embedding 모델 버전')
param embeddingModelVersion string = '1'

@description('모델 배포 용량 (단위: 1000 TPM)')
param modelCapacity int = 50

// ---------------------------------------------------------------------
// Azure AI Search
// ---------------------------------------------------------------------
var searchName = 'foundryiq-aisearch-${suffix}'

resource search 'Microsoft.Search/searchServices@2024-03-01-preview' = {
  name: searchName
  location: searchLocation
  sku: {
    name: searchSku
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    semanticSearch: searchSku == 'free' ? 'disabled' : 'free'
  }
}

// ---------------------------------------------------------------------
// Azure AI Foundry (AIServices account = Foundry 리소스)
// ---------------------------------------------------------------------
var foundryName = 'foundryiq-openai-dev-${suffix}'

resource foundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: foundryName
  location: foundryLocation
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: foundryName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    allowProjectManagement: true
  }
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  parent: foundry
  name: projectName
  location: foundryLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// ---------------------------------------------------------------------
// 모델 배포 (직렬 배포: deployments는 동시 생성 시 충돌이 잦음)
// ---------------------------------------------------------------------
resource chatDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = {
  parent: foundry
  name: chatDeploymentName
  sku: {
    name: 'GlobalStandard'
    capacity: modelCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4.1-mini'
      version: chatModelVersion
    }
  }
}

resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = {
  parent: foundry
  name: embeddingDeploymentName
  sku: {
    name: 'Standard'
    capacity: modelCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-large'
      version: embeddingModelVersion
    }
  }
  dependsOn: [
    chatDeployment
  ]
}

// ---------------------------------------------------------------------
// Outputs (.env 생성에 사용)
// ---------------------------------------------------------------------
output searchName string = search.name
output searchEndpoint string = 'https://${search.name}.search.windows.net'

output foundryName string = foundry.name
output foundryEndpoint string = foundry.properties.endpoint
output openAIEndpoint string = 'https://${foundry.name}.openai.azure.com/'
output projectEndpoint string = '${foundry.properties.endpoint}api/projects/${project.name}'

output chatDeploymentName string = chatDeployment.name
output embeddingDeploymentName string = embeddingDeployment.name
