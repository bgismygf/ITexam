# 4-2 IN / EXISTS / ANY / ALL 🎯

這四個都用來搭配「多列子查詢」。

## IN / NOT IN

```sql
WHERE question_id IN (SELECT question_id FROM practice_log)       -- 在清單中
WHERE question_id NOT IN (SELECT question_id FROM practice_log)   -- 不在清單中
```

### ⚠️ NOT IN 的 NULL 陷阱（重要！）

**子查詢的結果只要有一個 NULL，NOT IN 就會回傳空的結果。**

```sql
-- 想找「答案不在第 5 份考試答案中」的題目
-- 第 5 份考試的答案是 C、B、A、NULL、A
SELECT * FROM questions
WHERE answer NOT IN (SELECT answer FROM questions WHERE exam_id = 5);
-- 結果：0 筆！
```

原因（用 1-6 課的三值邏輯）：
```
answer NOT IN ('C', 'B', 'A', NULL)
= answer <> 'C' AND answer <> 'B' AND answer <> 'A' AND answer <> NULL
                                                         ↑ 永遠是 UNKNOWN
= ... AND UNKNOWN
= 最好的情況也只是 UNKNOWN，永遠不會是 TRUE
```

**解法**：
1. 子查詢加上 `WHERE 欄位 IS NOT NULL`
2. 改用 `NOT EXISTS`（不受 NULL 影響）

## EXISTS / NOT EXISTS

`EXISTS` 只檢查**子查詢有沒有回傳任何一列**，不在乎回傳什麼值。

```sql
-- 作答過的題目
SELECT * FROM questions q
WHERE EXISTS (SELECT 1 FROM practice_log p WHERE p.question_id = q.question_id);
```

- 子查詢裡寫 `SELECT 1`、`SELECT *` 都可以，因為只看「有沒有」
- 子查詢用到了外層的 `q.question_id`，這叫**相關子查詢**（下一課）
- 找到第一筆就停止，不用把全部結果找完

### IN vs EXISTS

| | IN | EXISTS |
|---|---|---|
| 判斷方式 | 值是否在清單中 | 子查詢是否有結果 |
| NULL 問題 | `NOT IN` 遇到 NULL 會出錯 | **不受影響** |
| 子查詢 | 通常是獨立的 | 通常是相關子查詢 |

💼 **工作建議**：要寫「不存在」的條件時，優先用 **`NOT EXISTS`** 或 **LEFT JOIN + IS NULL**，避開 NOT IN 的陷阱。

## ANY / ALL 🎯

> ⚠️ **SQLite 不支援 ANY / ALL**，本節只看講義，練習檔用等價寫法。
> MySQL、SQL Server、PostgreSQL、Oracle 都支援。

| 寫法 | 意思 | 等價寫法 |
|---|---|---|
| `x > ANY (子查詢)` | 比**其中任何一個**大就成立 | `x > (SELECT MIN(...))` |
| `x > ALL (子查詢)` | 比**全部**都大才成立 | `x > (SELECT MAX(...))` |
| `x < ANY (子查詢)` | 比其中任何一個小 | `x < (SELECT MAX(...))` |
| `x < ALL (子查詢)` | 比全部都小 | `x < (SELECT MIN(...))` |
| `x = ANY (子查詢)` | 等於其中一個 | **等於 `x IN (子查詢)`** |
| `x <> ALL (子查詢)` | 跟全部都不相等 | **等於 `x NOT IN (子查詢)`** |

`SOME` 和 `ANY` 意思完全一樣。

💡 **記法**：子查詢結果是 {2, 5, 8}
- `x > ANY` → 只要 > 2（最小的）就成立
- `x > ALL` → 必須 > 8（最大的）才成立

```sql
-- 薪水比「所有」業務部員工都高的人
SELECT * FROM emp
WHERE salary > ALL (SELECT salary FROM emp WHERE dept = '業務部');
```

## 小測驗

1. 子查詢回傳 {10, 20, 30}，下列條件何者成立時 x 一定大於 30？
   (A) x > ANY (B) x > ALL (C) x = ANY (D) x < ALL

2. 下列哪一個寫法與 `x IN (子查詢)` 等價？
   (A) x = ALL (B) x = ANY (C) x <> ANY (D) x > ANY

3. 子查詢結果為 {1, 2, NULL}，則 `3 NOT IN (子查詢)` 的結果為？
   (A) TRUE (B) FALSE (C) UNKNOWN (D) 錯誤

<details>
<summary>看答案</summary>

1. **(B)**
2. **(B)**
3. **(C)**。3 <> 1 為 TRUE，3 <> 2 為 TRUE，3 <> NULL 為 UNKNOWN；TRUE AND TRUE AND UNKNOWN = UNKNOWN
</details>
