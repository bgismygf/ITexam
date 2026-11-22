# 2-2 GROUP BY 分組 🎯💼

## 觀念

上一課的彙總函數，是把**整張表**算成一個值。
如果想要「**每一份考試**各有幾題」，就要先**分組**，再對每一組彙總。

```sql
SELECT exam_id, COUNT(*)
FROM questions
GROUP BY exam_id;
```

| exam_id | COUNT(*) |
|---|---|
| 1 | 6 |
| 2 | 7 |
| 3 | 6 |
| 4 | 6 |
| 5 | 5 |

## 圖解

```
questions 表                         GROUP BY exam_id           結果
┌─────────────┬─────────┐            ┌──────────────┐
│ question_id │ exam_id │    ───▶    │ exam_id = 1  │ 6 題   ─▶  1 | 6
│      1      │    1    │            │ (第1～6題)    │
│      2      │    1    │            ├──────────────┤
│     ...     │   ...   │            │ exam_id = 2  │ 7 題   ─▶  2 | 7
│      7      │    2    │            │ (第7～13題)   │
│     ...     │   ...   │            ├──────────────┤
└─────────────┴─────────┘            │     ...      │
                                     └──────────────┘
```

可以想成 Excel 的**樞紐分析表**：GROUP BY 的欄位是「列標籤」，彙總函數是「值」。

## 多欄位分組

```sql
SELECT year, subject, COUNT(*)
FROM exams
GROUP BY year, subject;
```
依「年度＋科目」的**組合**分組。

## 🎯 重要規則（必考）

**有 GROUP BY 時，SELECT 裡只能放：**
1. **GROUP BY 裡的欄位**
2. **彙總函數**
3. 常數

```sql
-- ✅ 正確
SELECT exam_id, COUNT(*) FROM questions GROUP BY exam_id;

-- ❌ 錯誤：content 不在 GROUP BY 裡，也不是彙總函數
SELECT exam_id, content, COUNT(*) FROM questions GROUP BY exam_id;
```

為什麼？每一組只會產生**一列**結果。exam_id = 1 那組有 6 題，content 有 6 個不同的值，
資料庫不知道要顯示哪一個。

⚠️ SQLite 和舊版 MySQL 不會報錯，會隨便挑一個值，但這是**錯誤的寫法**，
換到 SQL Server、PostgreSQL、Oracle 會直接報錯。

## NULL 的分組

GROUP BY 會把**所有 NULL 分在同一組**。

## 搭配 WHERE 和 ORDER BY

```sql
SELECT exam_id, COUNT(*) AS 題數
FROM questions
WHERE score >= 2          -- 1. 先篩選
GROUP BY exam_id          -- 2. 再分組
ORDER BY 題數 DESC;        -- 3. 最後排序
```

## 💼 工作小技巧

GROUP BY 是做報表的核心，常見用法：
- 每月營業額：`GROUP BY 年, 月`
- 每個部門人數：`GROUP BY 部門`
- 找出重複資料：`GROUP BY 身分證字號 HAVING COUNT(*) > 1`（下一課）

## 小測驗

1. 下列 SQL 何者在標準 SQL 中是錯誤的？
   (A) `SELECT dept, COUNT(*) FROM emp GROUP BY dept;`
   (B) `SELECT dept, name, COUNT(*) FROM emp GROUP BY dept;`
   (C) `SELECT dept, MAX(salary) FROM emp GROUP BY dept;`
   (D) `SELECT COUNT(*) FROM emp GROUP BY dept;`

<details>
<summary>看答案</summary>

**(B)**。name 不在 GROUP BY 裡，也不是彙總函數。
(D) 雖然看不出是哪個部門，但語法是正確的。
</details>
