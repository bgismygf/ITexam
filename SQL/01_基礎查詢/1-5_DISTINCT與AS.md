# 1-5 DISTINCT 與欄位別名 AS 🎯💼

## DISTINCT：去除重複

```sql
SELECT subject FROM exams;
-- 計算機原理、計算機原理、網路概論、計算機原理、網路概論（5 筆，有重複）

SELECT DISTINCT subject FROM exams;
-- 計算機原理、網路概論（2 筆）
```

### DISTINCT 作用在「整列」

```sql
SELECT DISTINCT year, subject FROM exams;
```
這裡是把「年度＋科目」的**組合**當成一個整體去重複，不是只對 year 去重複。
`DISTINCT` 只能寫在 `SELECT` 後面的第一個位置。

### NULL 也算一個值

`DISTINCT` 會把所有 NULL 視為相同，只保留一個。

## 🎯 考試重點：SQL 與關聯代數的差異

- **關聯代數**的投影 π **會自動去除重複**（因為關聯是「集合」，集合沒有重複元素）
- **SQL** 的 `SELECT` **預設不去除重複**，要加 `DISTINCT` 才會

也就是說：
- `SELECT DISTINCT subject FROM exams` ＝ π<sub>subject</sub>(exams)
- `SELECT subject FROM exams` 的結果是「多重集合（bag / multiset）」

## AS：欄位別名

替查詢結果的欄位取一個比較好懂的名字：

```sql
SELECT year AS 年度, subject AS 科目
FROM exams;
```

- `AS` 可以省略：`SELECT year 年度 FROM exams;`（但建議寫出來，比較清楚）
- 別名有空白或特殊字元時，用雙引號包起來：`AS "考試 年度"`
- 計算出來的欄位特別需要別名，否則欄名會是一長串算式：
  ```sql
  SELECT question_id, score * 2 AS double_score FROM questions;
  ```

### 資料表也可以取別名

```sql
SELECT q.question_id, q.content
FROM questions AS q;
```
現在看起來多此一舉，但到第 3 單元**多表查詢**時會大量使用。

### ⚠️ 別名能用在哪裡

| 子句 | 能不能用 SELECT 的欄位別名 |
|---|---|
| `ORDER BY` | ✅ 可以 |
| `WHERE` | ❌ 標準 SQL 不行（SQLite 可以，但不要依賴） |
| `GROUP BY` / `HAVING` | ❌ 標準 SQL 不行（MySQL、SQLite 可以） |

原因跟 SQL 的**執行順序**有關：WHERE 比 SELECT 先執行，那時候別名還不存在。
2-4 課會詳細說明。

## 💼 工作小技巧

- 用 `DISTINCT` 快速了解某個欄位有哪些值：`SELECT DISTINCT status FROM orders;`
- 如果你發現自己常常需要加 `DISTINCT` 才能讓結果正確，通常代表 JOIN 寫錯了，
  導致資料重複。先檢查 JOIN 條件，不要用 DISTINCT 硬蓋過去
- 報表給非技術人員看時，用中文別名會更友善

## 小測驗

1. 關於 SQL 的 SELECT 與關聯代數的投影，下列敘述何者正確？
   (A) 兩者都會自動去除重複
   (B) 兩者都不會去除重複
   (C) 投影會去除重複，SELECT 預設不會
   (D) SELECT 會去除重複，投影不會

2. `SELECT DISTINCT year, subject FROM exams;` 的作用是？
   (A) 只對 year 去重複
   (B) 只對 subject 去重複
   (C) 對 year 和 subject 的組合去重複
   (D) 語法錯誤

<details>
<summary>看答案</summary>

1. **(C)**
2. **(C)**
</details>
