# 1-1 SELECT 與 FROM 🎯💼

## 觀念

查詢資料是 SQL 最常做的事，工作上大概 80% 的 SQL 都是查詢。

一個最基本的查詢只需要兩個部分：
- **`SELECT`**：我要看**哪些欄位**
- **`FROM`**：從**哪張表**拿資料

```sql
SELECT 欄位1, 欄位2
FROM 資料表;
```

可以把它想成跟資料庫說：「請**給我**（SELECT）年度和科目，**從**（FROM）考試表。」

## 三種常見寫法

### 1. 查全部欄位：`*`
```sql
SELECT * FROM exams;
```
`*` 代表「所有欄位」。

### 2. 查指定欄位
```sql
SELECT year, subject FROM exams;
```
欄位之間用**逗號**分隔，結果會照你寫的順序排列。

### 3. 欄位可以做計算
```sql
SELECT question_id, score, score * 2 FROM questions;
```
計算結果只出現在查詢結果裡，**不會改到資料表裡的資料**。

### 4. 文字串接：`||`

`||`（兩條直線）把前後的值**接成一段文字**：

```sql
SELECT year || '年' FROM exams;
-- 110年、111年、112年……
```

| 片段 | 意思 |
|---|---|
| `year` | 欄位，值是數字 `110` |
| `'年'` | 文字，要用**單引號**（1-2 課） |
| `\|\|` | 把兩邊接起來，`110` 會自動轉成文字，結果是 `'110年'` |

可以一次接很多段，中間的空白也要自己用 `' '` 接進去：

```sql
SELECT year || '年 ' || subject FROM exams;
-- 110年 計算機原理、111年 計算機原理……
```

和上面的計算一樣，串接只影響**查詢結果**，資料表裡的 `year` 還是數字 `110`。

⚠️ 結果的欄位名稱會是一長串 `year || '年 ' || subject`，可以用 1-5 課的**別名**（AS）取個好懂的名字。

⚠️ 串接的值有 NULL 時，**整個結果會變成 NULL**（1-6 課）。

### 💼 各家資料庫的串接寫法不同

| 資料庫 | 寫法 |
|---|---|
| SQLite、PostgreSQL、Oracle | `year \|\| '年'` |
| MySQL | `CONCAT(year, '年')`。⚠️ MySQL 預設把 `\|\|` 當成邏輯運算的 OR，結果會變成 1 或 0，**不會出現錯誤訊息**，很難發現 |
| SQL Server | `CONCAT(year, '年')`。也可以用 `+`，但數字要先轉成文字：`CAST(year AS VARCHAR) + '年'` |

遇到 NULL 時也不一樣：Oracle 的 `||`，以及 PostgreSQL、SQL Server 的 `CONCAT()`，會把 NULL 當成**空字串**，不會讓整個結果變成 NULL。換資料庫時要測試一下。

完整的字串函數對照表在 4-7 課。

## 💼 工作小技巧

- **正式程式裡盡量不要用 `SELECT *`**：
  - 會撈出不需要的欄位，浪費傳輸和記憶體
  - 別人在資料表加了欄位，你的程式結果就會跟著變
  - `SELECT *` 適合自己臨時看資料的時候用
- 欄位多的時候，習慣一個欄位一行，比較好讀也好修改：
  ```sql
  SELECT
      question_id,
      content,
      score
  FROM questions;
  ```

## 🎯 考試重點

- `SELECT` 對應到關聯代數的**投影（Projection, π）**：選出特定的「欄」
  （第 6-8 課會正式介紹）
- `SELECT` 屬於 **DML（資料操作語言）**，有些書會另外把它歸類為 **DQL（資料查詢語言）**

## 常見錯誤

| 錯誤寫法 | 問題 |
|---|---|
| `SELECT year subject FROM exams;` | 少了逗號，SQL 會把 `subject` 當成 `year` 的別名（1-5 課會教別名） |
| `SELECT year, subject, FROM exams;` | 最後一個欄位後面多了逗號，會出現語法錯誤 |
| `SELECT * FORM exams;` | `FROM` 拼錯 |
| `SELECT year \|\| 年 FROM exams;` | `年` 沒加單引號，會被當成欄位名稱，出現「no such column: 年」 |

## 小測驗

1. 下列 SQL 中，哪一個關鍵字用來指定「從哪一張資料表」取資料？
   (A) SELECT (B) FROM (C) WHERE (D) TABLE

2. `SELECT` 指定欄位的動作，對應關聯代數的哪一種運算？
   (A) 選擇 σ (B) 投影 π (C) 合併 ⋈ (D) 聯集 ∪

3. 在 SQLite 中，`year` 的值是 `112`、`subject` 的值是 `'網路概論'`，`SELECT year || '-' || subject` 的結果是？
   (A) 112-網路概論 (B) 112 - 網路概論 (C) 111 (D) 語法錯誤

<details>
<summary>看答案</summary>

1. **(B)** FROM
2. **(B)** 投影 π
3. **(A)** `||` 把三段直接接在一起，不會自動加空白
</details>
