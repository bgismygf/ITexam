# 3-2 INNER JOIN 🎯💼

## 觀念

**JOIN（合併）** 是把兩張表依照某個條件「接起來」。

```sql
SELECT 欄位
FROM 表A
INNER JOIN 表B ON 表A.欄位 = 表B.欄位;
```

- `ON` 後面寫**合併條件**：兩張表靠哪個欄位對應
- `INNER` 可以省略，直接寫 `JOIN` 就是 INNER JOIN

## 範例：題目加上年度和科目

```sql
SELECT questions.question_id, questions.content, exams.year, exams.subject
FROM questions
INNER JOIN exams ON questions.exam_id = exams.exam_id;
```

### 用資料表別名縮短

```sql
SELECT q.question_id, q.content, e.year, e.subject
FROM questions AS q
JOIN exams AS e ON q.exam_id = e.exam_id;
```

💡 **習慣**：多表查詢時，**每個欄位都加上表的別名**（`q.`、`e.`），
一看就知道欄位來自哪張表，也能避免「欄位名稱不明確」的錯誤。

## 運作原理

```
questions                         exams
┌────┬─────────┐                  ┌─────────┬──────┐
│ id │ exam_id │                  │ exam_id │ year │
├────┼─────────┤                  ├─────────┼──────┤
│ 1  │    1    │ ─────────────▶   │    1    │ 110  │
│ 2  │    1    │ ─────────────▶   │    1    │ 110  │
│ 7  │    2    │ ─────────────▶   │    2    │ 111  │
└────┴─────────┘                  └─────────┴──────┘

對 questions 的每一列，去 exams 找 exam_id 相同的列，接在一起
```

## 🎯 INNER JOIN 只保留「兩邊都對得上」的資料

```
   表A        表B
  ┌────┐    ┌────┐
  │    │████│    │     INNER JOIN = 中間重疊的部分
  │    │████│    │
  └────┘    └────┘
```

如果某一列在另一張表找不到對應的資料，**就不會出現在結果中**。

例如：`questions JOIN practice_log`，從來沒被作答過的題目就不會出現。

## 一次 JOIN 多張表

```sql
SELECT q.question_id, q.content, t.name AS 章節
FROM questions q
JOIN question_topics qt ON q.question_id = qt.question_id
JOIN topics t           ON qt.topic_id   = t.topic_id;
```

一個接一個串下去。這是**多對多關係**的標準查法：
`questions ←→ question_topics ←→ topics`

## JOIN + WHERE + GROUP BY

JOIN 之後，就像一張大表，可以照常使用前兩個單元學的語法：

```sql
-- 每個章節各有幾題（顯示章節名稱）
SELECT t.name, COUNT(*) AS 題數
FROM question_topics qt
JOIN topics t ON qt.topic_id = t.topic_id
GROUP BY t.name
ORDER BY 題數 DESC;
```

## 舊式寫法（要看得懂）

```sql
SELECT q.content, e.year
FROM questions q, exams e
WHERE q.exam_id = e.exam_id;
```
結果跟 INNER JOIN 一樣。考試和舊系統裡常看到，但**新寫的 SQL 建議用 JOIN ... ON**，
因為合併條件和篩選條件分開，比較清楚，也比較不容易忘記寫條件。

## 🎯 考試重點

- **等值合併（Equi-Join）**：ON 條件用 `=`
- **自然合併（Natural Join）**：自動用**名稱相同的欄位**做等值合併，而且相同欄位只保留一個
  ```sql
  SELECT * FROM questions NATURAL JOIN exams;   -- 自動用 exam_id 合併
  ```
  ⚠️ 工作上**不建議使用**：如果兩張表剛好有其他同名欄位（例如都有 `name`），會被意外當成合併條件
- 關聯代數符號：**⋈**

## 💼 工作小技巧

- **忘記寫 ON 條件**（或條件寫錯）會產生大量重複資料，這是最常見的 JOIN bug。
  JOIN 之後先用 `COUNT(*)` 確認筆數合不合理
- 合併用的欄位（通常是外來鍵）要建索引，否則大表 JOIN 會非常慢（第 8 單元）

## 小測驗

1. INNER JOIN 的結果包含哪些資料？
   (A) 左表所有資料 (B) 右表所有資料 (C) 兩表中能互相對應的資料 (D) 兩表所有資料

2. 自動以兩表中「名稱相同的欄位」做等值合併，並去除重複欄位的是？
   (A) CROSS JOIN (B) NATURAL JOIN (C) LEFT JOIN (D) SELF JOIN

<details>
<summary>看答案</summary>

1. **(C)**
2. **(B)**
</details>
