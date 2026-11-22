# 9-1 View 檢視表 🎯💼

## 觀念

**檢視表（View）** 是一個「**存起來的查詢**」，用起來像一張資料表，但**本身不存資料**
（又稱為**虛擬資料表 Virtual Table**）。每次查詢 View 時，資料庫才去執行背後的 SQL。

```sql
CREATE VIEW v_question_detail AS
SELECT q.question_id, e.year, e.subject, q.question_no, q.content, q.answer
FROM questions q
JOIN exams e ON q.exam_id = e.exam_id;

-- 之後就像查資料表一樣
SELECT * FROM v_question_detail WHERE year = 113;
```

和 4-5 課的 CTE 比較：CTE 只在一句 SQL 中有效，**View 會永久保存在資料庫中**，大家都能用。

## 語法

```sql
CREATE VIEW 名稱 AS SELECT ...;
DROP VIEW 名稱;
-- 修改：SQLite 要先 DROP 再 CREATE
-- SQL Server：ALTER VIEW；MySQL / PostgreSQL / Oracle：CREATE OR REPLACE VIEW
```

## 🎯 View 的優點（常考）

| 優點 | 說明 |
|---|---|
| **簡化查詢** | 把複雜的 JOIN 包起來，使用者只要 `SELECT * FROM view` |
| **安全性** | 只開放部分欄位或部分資料給使用者（例如隱藏薪資欄位），搭配 9-4 課的權限 |
| **邏輯資料獨立性** | 底層資料表結構改變時，只要修改 View 的定義，使用 View 的程式不用改（0-2 課的「外部層」） |
| **一致性** | 大家都用同一個 View 計算報表，不會每個人算法不同 |

## 缺點

- 查詢 View 時才執行，複雜的 View 可能**很慢**
- View 裡面再用 View，層層包裝，不容易除錯和最佳化

## 🎯 可更新的 View

能不能對 View 做 `INSERT` / `UPDATE` / `DELETE`？

**一般來說，View 必須符合以下條件才能更新**（各家規定略有不同）：
- 只來自**一張**基底資料表
- **沒有** `DISTINCT`、`GROUP BY`、`HAVING`、彙總函數
- **沒有** `UNION`
- 包含基底表中所有 `NOT NULL` 且沒有預設值的欄位（才能 INSERT）

原因：資料庫必須能**明確知道**要修改基底表的哪一列。
例如 View 是 `SELECT exam_id, COUNT(*)`，把 COUNT 改成 10 是什麼意思？無法對應。

> ⚠️ SQLite 的 View **都是唯讀的**，要更新需要用 `INSTEAD OF` Trigger（9-3 課）。

### WITH CHECK OPTION

```sql
CREATE VIEW v_113 AS SELECT * FROM exams WHERE year = 113
WITH CHECK OPTION;
```
透過這個 View 新增或修改的資料，**必須符合 View 的 WHERE 條件**，否則拒絕。
（避免透過 v_113 新增一筆 110 年的資料，新增完卻在 View 裡看不到）

## 💼 實體化檢視表（Materialized View）

一般 View 每次查詢都重新計算。**實體化檢視表**會把結果**實際存起來**：
- 查詢很快（像查一般資料表）
- 但資料可能不是最新的，需要定期**更新（Refresh）**
- 適合複雜的報表統計
- PostgreSQL、Oracle 支援；SQL Server 叫「索引檢視表（Indexed View）」；MySQL、SQLite 不支援

## 小測驗

1. 下列關於 View 的敘述，何者錯誤？
   (A) View 是虛擬資料表
   (B) View 可以提供資料安全性
   (C) View 會實際儲存一份資料的副本
   (D) View 可以簡化複雜的查詢

2. 下列哪一種 View 最可能是「可更新」的？
   (A) 含有 GROUP BY 的 View
   (B) 合併兩張表的 View
   (C) 從單一表選取部分欄位與列的 View
   (D) 含有 DISTINCT 的 View

<details>
<summary>看答案</summary>

1. **(C)** 那是實體化檢視表
2. **(C)**
</details>
