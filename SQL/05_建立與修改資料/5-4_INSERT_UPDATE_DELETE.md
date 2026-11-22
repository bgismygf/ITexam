# 5-4 INSERT、UPDATE、DELETE 🎯💼

## INSERT：新增資料

### 指定欄位（建議寫法）

```sql
INSERT INTO 資料表 (欄位1, 欄位2, ...)
VALUES (值1, 值2, ...);
```

- 沒列出的欄位會用 DEFAULT 值，沒有 DEFAULT 就是 NULL
- 💼 **一定要寫欄位名稱**：表結構改變（例如新增欄位）時，才不會出錯或塞錯欄位

### 不指定欄位

```sql
INSERT INTO 資料表 VALUES (值1, 值2, ...);
```
必須**依照欄位順序、提供所有欄位**的值。

### 一次新增多筆

```sql
INSERT INTO topics (name) VALUES ('雲端運算'), ('人工智慧'), ('軟體工程');
```

### 從查詢結果新增

```sql
INSERT INTO 備份表 (欄位...)
SELECT 欄位... FROM 原表 WHERE 條件;
```

## UPDATE：修改資料

```sql
UPDATE 資料表
SET 欄位1 = 新值1, 欄位2 = 新值2
WHERE 條件;
```

```sql
UPDATE questions SET answer = 'C' WHERE question_id = 29;   -- 補上第 29 題的答案
UPDATE questions SET score = score + 0.5 WHERE exam_id = 1; -- 可以用原本的值計算
```

## DELETE：刪除資料

```sql
DELETE FROM 資料表 WHERE 條件;
```

## ⚠️⚠️⚠️ 最重要的一件事：WHERE

**UPDATE 和 DELETE 忘記寫 WHERE，會改掉 / 刪掉整張表的資料！**

```sql
DELETE FROM practice_log;                     -- 💀 全部作答紀錄都不見了
UPDATE questions SET answer = 'A';            -- 💀 所有題目的答案都變成 A
```

這是工作上最常見、後果最嚴重的錯誤之一。

### 💼 安全操作流程（養成習慣）

1. **先用 SELECT 確認範圍**
   ```sql
   SELECT * FROM questions WHERE exam_id = 1;     -- 確認是這 6 筆
   ```
2. **把 SELECT 改成 UPDATE / DELETE**，WHERE 條件不動
   ```sql
   UPDATE questions SET score = 2 WHERE exam_id = 1;
   ```
3. **看「影響的列數」是否跟步驟 1 一致**（DB Browser 會顯示「n rows affected」）
4. **正式環境**：先備份（`CREATE TABLE ... AS SELECT`），或包在交易中（第 7 單元），確認無誤才 COMMIT

## UPDATE 搭配子查詢

```sql
-- 把「被作答過的題目」配分加 0.5
UPDATE my_questions
SET score = score + 0.5
WHERE question_id IN (SELECT question_id FROM practice_log);
```

## 💼 UPSERT：有就更新、沒有就新增

```sql
-- SQLite / PostgreSQL
INSERT INTO t (id, name) VALUES (1, '新名字')
ON CONFLICT (id) DO UPDATE SET name = excluded.name;
```
MySQL 用 `ON DUPLICATE KEY UPDATE`，SQL Server / Oracle 用 `MERGE`。

## 🎯 考試重點

- INSERT、UPDATE、DELETE 都屬於 **DML**
- 違反限制條件（主鍵重複、外來鍵不存在等）時，整句 SQL 會失敗，不會只寫入一部分

## 小測驗

1. 執行 `DELETE FROM emp;` 的結果為？
   (A) 語法錯誤 (B) 刪除 emp 資料表 (C) 刪除 emp 的所有資料，但保留表結構 (D) 只刪除第一筆

2. 要將所有員工薪水調高 10%，下列何者正確？
   (A) `ALTER emp SET salary = salary * 1.1;`
   (B) `UPDATE emp SET salary = salary * 1.1;`
   (C) `UPDATE emp salary = salary * 1.1;`
   (D) `MODIFY emp SET salary = salary * 1.1;`

<details>
<summary>看答案</summary>

1. **(C)**
2. **(B)**
</details>
