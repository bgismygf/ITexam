# 1-3 BETWEEN、IN、LIKE、IS NULL 🎯💼

這四個是 `WHERE` 裡最常用的「特殊條件」，可以讓條件寫得更簡潔。

## BETWEEN：範圍

```sql
WHERE year BETWEEN 111 AND 113
-- 等同於
WHERE year >= 111 AND year <= 113
```

🎯 **重點**：`BETWEEN` **包含頭尾兩端**（111 和 113 都算）。

`NOT BETWEEN` 則是範圍以外：
```sql
WHERE year NOT BETWEEN 111 AND 113   -- 小於 111 或大於 113
```

## IN：列舉多個值

```sql
WHERE exam_id IN (1, 3, 5)
-- 等同於
WHERE exam_id = 1 OR exam_id = 3 OR exam_id = 5
```

`NOT IN` 則是「不在清單裡」：
```sql
WHERE answer NOT IN ('A', 'B')
```

## LIKE：模糊比對文字

用**萬用字元**比對部分文字：

| 萬用字元 | 意思 | 範例 | 符合 |
|---|---|---|---|
| `%` | 任意長度（含 0 個字）的任何字元 | `'%資料%'` | 含有「資料」的文字 |
| `_` | **剛好一個**任意字元 | `'_PS'` | 3 個字、後兩個是 PS |

常見用法：

| 寫法 | 意思 |
|---|---|
| `LIKE '下列%'` | 以「下列」**開頭** |
| `LIKE '%？'` | 以「？」**結尾** |
| `LIKE '%TCP%'` | **含有** TCP |
| `LIKE '__'` | 剛好 **2 個字** |

⚠️ **大小寫**：SQLite 的 `LIKE` 對英文字母**不分大小寫**；MySQL 通常也不分；PostgreSQL 分大小寫（要用 `ILIKE`）。

💡 **類比**：Windows 搜尋檔案時的 `*.txt`，`*` 就像 SQL 的 `%`。

## IS NULL：判斷空值

```sql
WHERE answer IS NULL       -- ✅ 正確
WHERE answer = NULL        -- ❌ 永遠查不到任何資料！
WHERE answer IS NOT NULL   -- 有值的資料
```

🎯 **必考**：判斷 NULL **一定要用 `IS NULL`**，不能用 `= NULL`。
原因是 NULL 代表「未知」，「未知等不等於未知」的答案還是「未知」，不是「是」。
1-6 課會詳細說明。

## 💼 工作小技巧

- `LIKE '%關鍵字%'`（開頭就是 %）**無法使用索引**，資料量大時會很慢。
  `LIKE '關鍵字%'`（開頭固定）則可以用索引（第 8 單元）
- `IN` 清單很長（例如上千個值）時，效能可能不好，可以改用 JOIN 或子查詢（第 3、4 單元）
- ⚠️ `NOT IN` 的清單裡如果有 NULL，結果會是**空的**，這是很常見的 bug（第 4-2 課）

## 小測驗

1. `WHERE score BETWEEN 2 AND 3` 會包含哪些分數？
   (A) 2 < score < 3 (B) 2 <= score < 3 (C) 2 < score <= 3 (D) 2 <= score <= 3

2. 要找出姓名第二個字是「明」的人，條件應該寫？
   (A) `LIKE '%明%'` (B) `LIKE '_明%'` (C) `LIKE '明%'` (D) `LIKE '%明'`

3. 要查出電話欄位（phone）沒有資料的員工，條件應該寫？
   (A) `phone = NULL` (B) `phone IS NULL` (C) `phone = ''` (D) `phone = 0`

<details>
<summary>看答案</summary>

1. **(D)** BETWEEN 包含頭尾
2. **(B)** `_` 代表第一個字（任意），接著是「明」，後面 `%` 是任意長度
3. **(B)** 判斷 NULL 要用 IS NULL
</details>
