# 1-2 WHERE 條件 🎯💼

## 觀念

`WHERE` 用來**篩選列（Row）**，只留下符合條件的資料。

```sql
SELECT 欄位
FROM 資料表
WHERE 條件;
```

例如：「給我 **113 年**的考試」
```sql
SELECT * FROM exams
WHERE year = 113;
```

## 比較運算子

| 運算子 | 意思 | 範例 |
|---|---|---|
| `=` | 等於 | `year = 113` |
| `<>` 或 `!=` | 不等於 | `subject <> '網路概論'` |
| `>` | 大於 | `score > 2` |
| `>=` | 大於等於 | `score >= 2` |
| `<` | 小於 | `year < 112` |
| `<=` | 小於等於 | `year <= 112` |

⚠️ SQL 的「等於」是**一個** `=`，不是程式語言常見的 `==`。
`<>` 是 SQL 標準寫法，`!=` 大部分資料庫也支援。

## 文字要加單引號

```sql
WHERE subject = '網路概論'    -- ✅ 正確
WHERE subject = 網路概論      -- ❌ 會被當成欄位名稱
WHERE subject = "網路概論"    -- ⚠️ 有些資料庫會把雙引號當欄位名稱，不要用
```

## 邏輯運算子：AND、OR、NOT

| 運算子 | 意思 | 範例 |
|---|---|---|
| `AND` | 兩個條件**都要**成立 | `year = 113 AND subject = '網路概論'` |
| `OR` | **任一個**條件成立就可以 | `year = 110 OR year = 113` |
| `NOT` | 條件**相反** | `NOT subject = '網路概論'` |

### ⚠️ 優先順序：NOT > AND > OR

這是新手最常出錯的地方：

```sql
-- 想要：113 年的考試，科目是計算機原理或網路概論
-- ❌ 錯誤寫法
WHERE year = 113 AND subject = '計算機原理' OR subject = '網路概論'
-- 實際被解讀成：(year = 113 AND subject = '計算機原理') OR subject = '網路概論'
-- 結果會把 112 年的網路概論也查出來！

-- ✅ 正確寫法：加括號
WHERE year = 113 AND (subject = '計算機原理' OR subject = '網路概論')
```

💡 **習慣**：只要 `AND` 和 `OR` 同時出現，就加括號，不要靠記優先順序。

## 💼 工作小技巧

- 在正式資料庫執行 `UPDATE` 或 `DELETE` 之前，**先用 `SELECT ... WHERE` 確認會影響哪些資料**，
  確認無誤再改成 UPDATE / DELETE（第 5 單元會再強調）
- 數字欄位不要加引號比較，例如 `year = '113'`。有些資料庫會自動轉型，但會影響效能，
  甚至造成索引失效（第 8 單元）

## 🎯 考試重點

- `WHERE` 對應關聯代數的**選擇（Selection, σ）**：選出特定的「列」
- 分清楚：**選擇 σ 選列（WHERE）**，**投影 π 選欄（SELECT）**

## 小測驗

1. 下列哪一個條件，可以查出「110 年或 111 年，且配分大於 2」的題目？（假設表中有 year 和 score）
   (A) `year = 110 OR year = 111 AND score > 2`
   (B) `(year = 110 OR year = 111) AND score > 2`
   (C) `year = 110 AND year = 111 AND score > 2`
   (D) `year = 110 OR (year = 111 AND score > 2)`

2. SQL 中的 WHERE 子句，對應關聯代數的哪一種運算？
   (A) 投影 (B) 選擇 (C) 合併 (D) 除法

<details>
<summary>看答案</summary>

1. **(B)**。(A) 和 (D) 意思相同，因為 AND 比 OR 優先；(C) 一個年度不可能同時是 110 又是 111，永遠查不到資料。
2. **(B)** 選擇 σ
</details>
