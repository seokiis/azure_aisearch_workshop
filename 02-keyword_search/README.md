# 2️⃣ 키워드 검색 실습 (Keyword Search)

## 🎯 이 폴더에서 얻어갈 수 있는 것

이 실습을 완료하면 다음을 할 수 있게 됩니다:

| 학습 항목 | 설명 |
|----------|------|
| **📐 인덱스 스키마 설계** | `SimpleField`, `SearchableField` 등 필드 타입과 속성(`searchable`, `filterable`, `sortable`, `facetable`)의 차이를 이해합니다 |
| **🇰🇷 한국어 분석기 적용** | `ko.lucene` 분석기를 통한 한글 형태소 분석과 토큰화 원리를 파악합니다 |
| **📤 데이터 업로드** | CSV 데이터를 배치 처리하여 Azure AI Search 인덱스에 업로드하는 방법을 익힙니다 |
| **🔍 BM25 키워드 검색** | 전통적인 텍스트 매칭 알고리즘(BM25)의 동작 원리와 검색 점수(`@search.score`)를 이해합니다 |
| **🎛️ OData 필터 문법** | `eq`, `le`, `ge`, `and`, `or` 등의 필터 조건으로 검색 범위를 좁히는 방법을 배웁니다 |
| **📊 Facet 집계** | 카테고리별, 브랜드별 집계를 통해 검색 결과의 분포를 분석합니다 |
| **↕️ 정렬 기능** | 가격순, 인기순 등 비즈니스 요구에 맞는 정렬 구현 방법을 익힙니다 |

### 📓 노트북 학습 순서

| 순서 | 노트북 | 핵심 내용 |
|------|--------|----------|
| 1️⃣ | [01-create_index.ipynb](./01-create_index.ipynb) | 인덱스 스키마 정의, 필드 속성 설정, 벡터 검색 설정 준비 |
| 2️⃣ | [02-upload_data.ipynb](./02-upload_data.ipynb) | CSV → 문서 변환, 배치 업로드, 업로드 결과 검증 |
| 3️⃣ | [03-keyword_search.ipynb](./03-keyword_search.ipynb) | 기본 검색, 필터링, 정렬, Facet 집계 실습 |

---

Azure AI Search의 키워드 검색 기능을 실습합니다. 인덱스 생성부터 데이터 업로드, 검색까지 전체 흐름을 학습합니다.

## 📋 목차

1. [키워드 검색이란?](#1-키워드-검색이란)
2. [실습 흐름](#2-실습-흐름)
3. [인덱스 생성](#3-인덱스-생성)
4. [데이터 업로드](#4-데이터-업로드)
5. [키워드 검색 실습](#5-키워드-검색-실습)

---

## 1. 키워드 검색이란?

### 1.1 키워드 검색의 특징

키워드 검색(Keyword Search)은 **텍스트 매칭 기반** 검색 방법입니다:

- ✅ **정확한 단어 매칭**: 사용자가 입력한 키워드와 문서의 단어를 직접 비교
- ✅ **빠른 검색 속도**: 인덱싱된 단어 기반으로 빠르게 검색
- ✅ **필터링 & 정렬**: 카테고리, 가격 등으로 필터링 및 정렬 가능
- ✅ **한국어 분석기**: `ko.lucene` 분석기로 한국어 형태소 분석

### 1.2 언제 사용하나요?

- 특정 상품명, 브랜드명을 정확히 찾을 때
- 카테고리별, 가격대별 필터링이 필요할 때
- 빠른 응답 속도가 중요할 때

---

## 2. 실습 흐름

```
📊 데이터 준비 (sample_data.csv)
         ↓
🔧 인덱스 생성 (필드 정의)
         ↓
📤 데이터 업로드
         ↓
🔍 키워드 검색 실습
```

### 2.1 사용할 데이터셋

`../00-data/sample_data.csv` (247개 상품 데이터):

```csv
id,title,brand,category,normal_price,image_link
1,압소바6 (ATA367P2M13) 레코딸랑이세트(신생아 백일 선물),압소바,유아동,39000,https://...
2,[압소바] 출산선물 티노딸랑이세트 (선물포장) (ATA367P1),압소바,유아동,40000,https://...
...
```

---

## 3. 인덱스 생성

### 3.1 키워드 검색용 필드 정의

키워드 검색에 필요한 핵심 필드만 정의합니다:

| 필드명 | 타입 | 속성 | 설명 |
|--------|------|------|------|
| `id` | String | **key**, filterable | 문서 고유 식별자 |
| `title` | String | **searchable** (ko.lucene) | 상품명 (검색 대상) |
| `brand` | String | **searchable**, filterable, facetable | 브랜드명 |
| `category` | String | filterable, facetable | 카테고리 |
| `normal_price` | Int32 | filterable, **sortable** | 가격 |
| `image_link` | String | retrievable | 이미지 URL |

### 3.2 인덱스 생성 스크립트

**`create_index.py`** 파일 내용:

```python
"""
키워드 검색용 Azure AI Search Index 생성
"""
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (
    SearchIndex,
    SimpleField,
    SearchableField,
    SearchFieldDataType
)
from azure.core.credentials import AzureKeyCredential
from dotenv import load_dotenv
import os

load_dotenv()

def create_keyword_index():
    """키워드 검색용 인덱스 생성"""
    
    # 환경 변수 로드
    endpoint = os.getenv("SEARCH_ENDPOINT")
    key = os.getenv("SEARCH_ADMIN_KEY")
    index_name = os.getenv("SEARCH_INDEX_NAME")
    
    # 클라이언트 초기화
    credential = AzureKeyCredential(key)
    client = SearchIndexClient(endpoint=endpoint, credential=credential)
    
    # 키워드 검색용 필드 정의
    fields = [
        SimpleField(
            name="id",
            type=SearchFieldDataType.String,
            key=True,  # 필수: 고유 식별자
            filterable=True
        ),
        SearchableField(
            name="title",
            type=SearchFieldDataType.String,
            analyzer_name="ko.lucene"  # 한국어 형태소 분석
        ),
        SearchableField(
            name="brand",
            type=SearchFieldDataType.String,
            filterable=True,
            facetable=True
        ),
        SimpleField(
            name="category",
            type=SearchFieldDataType.String,
            filterable=True,
            facetable=True
        ),
        SimpleField(
            name="normal_price",
            type=SearchFieldDataType.Int32,
            filterable=True,
            sortable=True
        ),
        SimpleField(
            name="image_link",
            type=SearchFieldDataType.String
        )
    ]
    
    # 인덱스 생성
    index = SearchIndex(
        name=index_name,
        fields=fields
    )
    
    try:
        result = client.create_or_update_index(index)
        print(f"✅ Index '{index_name}' 생성 완료!")
        print(f"   - 필드 수: {len(result.fields)}")
        print(f"   - 검색 가능 필드: title, brand")
        print(f"   - 필터 가능 필드: brand, category, normal_price")
        return True
    except Exception as e:
        print(f"❌ Index 생성 실패: {str(e)}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print(" 키워드 검색용 Index 생성".center(60))
    print("=" * 60 + "\n")
    
    create_keyword_index()
```

### 3.3 실행

```bash
python create_index.py
```

---

## 4. 데이터 업로드

### 4.1 데이터 업로드 스크립트

**`upload_data.py`** 파일 내용:

```python
"""
샘플 데이터를 Azure AI Search Index에 업로드
"""
import pandas as pd
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
from dotenv import load_dotenv
import os

load_dotenv()

def upload_keyword_data(csv_file):
    """CSV 데이터를 Index에 업로드"""
    
    # 환경 변수 로드
    endpoint = os.getenv("SEARCH_ENDPOINT")
    key = os.getenv("SEARCH_ADMIN_KEY")
    index_name = os.getenv("SEARCH_INDEX_NAME")
    
    # 클라이언트 초기화
    credential = AzureKeyCredential(key)
    client = SearchClient(endpoint=endpoint, index_name=index_name, credential=credential)
    
    # CSV 읽기
    df = pd.read_csv(csv_file)
    
    # 문서 준비
    documents = []
    for _, row in df.iterrows():
        doc = {
            "id": str(row['id']),  # String 타입으로 변환
            "title": row['title'],
            "brand": row['brand'],
            "category": row['category'],
            "normal_price": int(row['normal_price']),
            "image_link": row['image_link']
        }
        documents.append(doc)
    
    print(f"📊 총 {len(documents)}개 상품 업로드 중...\n")
    
    try:
        # 배치 업로드 (한 번에 1000개까지 가능)
        batch_size = 100
        total = len(documents)
        
        for i in range(0, total, batch_size):
            batch = documents[i:i+batch_size]
            result = client.upload_documents(documents=batch)
            
            succeeded = len([r for r in result if r.succeeded])
            failed = len([r for r in result if not r.succeeded])
            
            print(f"📤 [{i+succeeded}/{total}] 업로드 완료 (성공: {succeeded}, 실패: {failed})")
        
        print(f"\n✅ 모든 데이터 업로드 완료!")
        return True
        
    except Exception as e:
        print(f"❌ 업로드 실패: {str(e)}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print(" 데이터 업로드".center(60))
    print("=" * 60 + "\n")
    
    csv_file = "../00-data/sample_data.csv"
    upload_keyword_data(csv_file)
```

### 4.2 실행

```bash
python upload_data.py
```

---

## 5. 키워드 검색 실습

### 5.1 기본 키워드 검색

**`keyword_search.py`** 파일 내용:

```python
"""
키워드 검색 실습
"""
from azure.search.documents import SearchClient
from azure.core.credentials import AzureKeyCredential
from dotenv import load_dotenv
import os

load_dotenv()

def keyword_search(query, top=5):
    """키워드 검색 수행"""
    
    endpoint = os.getenv("SEARCH_ENDPOINT")
    key = os.getenv("SEARCH_ADMIN_KEY")
    index_name = os.getenv("SEARCH_INDEX_NAME")
    
    credential = AzureKeyCredential(key)
    client = SearchClient(endpoint=endpoint, index_name=index_name, credential=credential)
    
    # 검색 실행
    results = client.search(
        search_text=query,
        top=top,
        include_total_count=True
    )
    
    print(f"\n🔍 검색어: '{query}'")
    print(f"📊 총 {results.get_count()}개 결과 (상위 {top}개 표시)\n")
    print("=" * 80)
    
    for idx, result in enumerate(results, 1):
        print(f"{idx}. {result['title']}")
        print(f"   브랜드: {result['brand']} | 카테고리: {result['category']} | 가격: {result['normal_price']:,}원")
        print(f"   점수: {result['@search.score']:.2f}")
        print()
    
    return results

if __name__ == "__main__":
    print("=" * 80)
    print(" 키워드 검색 실습".center(80))
    print("=" * 80)
    
    # 예제 1: 상품명 검색
    keyword_search("압소바", top=3)
    
    # 예제 2: 브랜드 검색
    keyword_search("노스페이스", top=3)
    
    # 예제 3: 카테고리 검색
    keyword_search("신발", top=3)
```

### 5.2 필터링 검색

```python
def filtered_search(query, category=None, max_price=None):
    """필터링을 적용한 검색"""
    
    client = SearchClient(endpoint, index_name, AzureKeyCredential(key))
    
    # 필터 조건 생성
    filters = []
    if category:
        filters.append(f"category eq '{category}'")
    if max_price:
        filters.append(f"normal_price le {max_price}")
    
    filter_str = " and ".join(filters) if filters else None
    
    # 검색 실행
    results = client.search(
        search_text=query,
        filter=filter_str,
        top=5
    )
    
    print(f"\n🔍 검색어: '{query}'")
    if filter_str:
        print(f"🎯 필터: {filter_str}")
    
    for result in results:
        print(f"- {result['title']} ({result['normal_price']:,}원)")

# 예제: 5만원 이하 유아동 상품 검색
filtered_search("선물", category="유아동", max_price=50000)
```

### 5.3 정렬 검색

```python
def sorted_search(query, order_by="normal_price"):
    """정렬을 적용한 검색"""
    
    client = SearchClient(endpoint, index_name, AzureKeyCredential(key))
    
    results = client.search(
        search_text=query,
        order_by=[f"{order_by} asc"],  # asc: 오름차순, desc: 내림차순
        top=5
    )
    
    print(f"\n🔍 검색어: '{query}' (가격 낮은 순)")
    
    for result in results:
        print(f"- {result['title']} ({result['normal_price']:,}원)")

# 예제: 가격 낮은 순으로 정렬
sorted_search("가방")
```

### 5.4 패싯 검색 (카테고리별 집계)

```python
def faceted_search(query):
    """패싯(집계) 검색"""
    
    client = SearchClient(endpoint, index_name, AzureKeyCredential(key))
    
    results = client.search(
        search_text=query,
        facets=["category", "brand"],
        top=0  # 집계만 확인
    )
    
    print(f"\n🔍 검색어: '{query}' - 카테고리별 분포")
    
    # 카테고리별 개수
    for facet in results.get_facets()["category"]:
        print(f"- {facet['value']}: {facet['count']}개")
    
    print(f"\n브랜드별 분포:")
    for facet in results.get_facets()["brand"][:5]:  # 상위 5개만
        print(f"- {facet['value']}: {facet['count']}개")

# 예제: 검색 결과의 카테고리/브랜드 분포
faceted_search("*")  # 전체 데이터 집계
```

### 5.5 실행

```bash
python keyword_search.py
```

---

## ✅ 체크리스트

키워드 검색 실습이 완료되었는지 확인하세요:

- [ ] 키워드 검색 개념 이해
- [ ] 인덱스 생성 성공 (`create_index.py`)
- [ ] 샘플 데이터 업로드 완료 (`upload_data.py`)
- [ ] 기본 키워드 검색 성공 (`keyword_search.py`)
- [ ] 필터링 검색 테스트
- [ ] 정렬 검색 테스트
- [ ] Azure Portal에서 검색 탐색기로 확인

---

## 🧪 테스트

### Azure Portal에서 확인

1. **Azure Portal** → **Azure AI Search 리소스** 접속
2. 좌측 메뉴에서 **"인덱스"** 선택
3. 생성한 인덱스 클릭
4. **"검색 탐색기"** 클릭

**검색 예제:**
```json
{
  "search": "압소바",
  "top": 5
}
```

**필터링 예제:**
```json
{
  "search": "선물",
  "filter": "category eq '유아동' and normal_price le 50000",
  "top": 5
}
```

### 터미널에서 빠른 테스트

```bash
# 1. 인덱스 생성
python create_index.py

# 2. 데이터 업로드
python upload_data.py

# 3. 키워드 검색 실행
python keyword_search.py
```

---

## 📊 검색 결과 예시

### 예제 1: 브랜드 검색
```
🔍 검색어: '노스페이스'
📊 총 5개 결과

1. 노스페이스 NJ2HR11 남성 패커블 LT 자켓
   브랜드: 노스페이스 | 카테고리: 스포츠/레져 | 가격: 155,800원
   점수: 5.23

2. 노스페이스 NJ2HR41 여성 패커블 LT 자켓
   브랜드: 노스페이스 | 카테고리: 스포츠/레져 | 가격: 155,800원
   점수: 5.23
```

### 예제 2: 필터링 검색
```
🔍 검색어: '선물'
🎯 필터: category eq '유아동' and normal_price le 50000

- 압소바6 레코딸랑이세트(신생아 백일 선물) (39,000원)
- 출산선물 티노딸랑이세트 (40,000원)
- 에뜨와 코니딸랑이세트(6종) (38,000원)
```

---

## 🚀 다음 단계

키워드 검색 실습이 완료되었습니다! 이제 더 고급 검색 기능을 학습하세요:

1. **벡터 검색 (Vector Search)** - 의미 기반 검색
2. **하이브리드 검색 (Hybrid Search)** - 키워드 + 벡터 검색 결합
3. **시맨틱 검색 (Semantic Search)** - AI 기반 재순위화

---

## 💡 키워드 검색 팁

### 1. 한국어 분석기 (`ko.lucene`)
- **형태소 분석**: "노트북가방" → "노트북", "가방"으로 분리
- **동의어 처리**: "신발", "구두" 등을 동일하게 검색
- **불용어 제거**: "이", "그", "저" 등 의미 없는 단어 제외

### 2. 검색 점수 (@search.score)
- 높을수록 관련성이 높은 결과
- **TF-IDF** 알고리즘 기반
- 검색어가 문서에 자주 등장할수록 점수 상승

### 3. 필터 vs 검색
- **필터**: 정확히 일치하는 결과만 (빠름, 점수 없음)
- **검색**: 유사한 결과도 포함 (느림, 점수 있음)

### 4. 정렬 최적화
- `sortable` 속성이 설정된 필드만 정렬 가능
- 숫자, 날짜 필드에 적합
- 정렬은 점수 무시 (관련성 대신 지정된 기준 사용)

---

## 🆘 문제 해결

### Q1: "Index not found" 오류
**A**: 인덱스 이름을 확인하세요. `.env` 파일의 `SEARCH_INDEX_NAME` 값과 일치해야 합니다.

### Q2: 한글 검색이 제대로 안 됨
**A**: 
- `analyzer_name="ko.lucene"` 설정 확인
- Azure AI Search는 자동으로 형태소 분석을 수행합니다
- 예: "노트북" 검색 시 "노트북가방"도 검색됨

### Q3: 검색 결과가 없음
**A**:
- 데이터가 업로드되었는지 확인: Azure Portal → 인덱스 → 문서 개수
- 검색어 철자 확인
- 와일드카드 검색 시도: `search="*"` (전체 검색)

### Q4: 필터 문법 오류
**A**: OData 필터 문법 확인
```python
# 올바른 문법
"category eq '유아동'"           # 문자열은 작은따옴표
"normal_price le 50000"          # 숫자는 따옴표 없음
"category eq '유아동' and normal_price le 50000"  # AND 조건
```

### Q5: 성능이 느림
**A**:
- `top` 파라미터로 결과 수 제한 (기본값: 50)
- 필터를 먼저 적용하여 검색 범위 축소
- 필요한 필드만 `select`로 지정

---

## 📚 추가 학습 자료

- [Azure AI Search 문서](https://learn.microsoft.com/azure/search/)
- [OData 필터 문법](https://learn.microsoft.com/azure/search/search-query-odata-filter)
- [한국어 분석기 상세](https://learn.microsoft.com/azure/search/index-add-language-analyzers)
- [검색 점수 알고리즘](https://learn.microsoft.com/azure/search/index-similarity-and-scoring)
