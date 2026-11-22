# 4-5 CTE（WITH 子句） 💼

## 觀念

**CTE（Common Table Expression，通用資料表運算式）** 用 `WITH` 先替子查詢**取一個名字**，
後面的主查詢就可以像使用資料表一樣使用它。

```sql
WITH 名稱 AS (
    子查詢
)
SELECT ... FROM 名稱;
```

## 為什麼要用 CTE：可讀性

同一個需求，子查詢寫法 vs CTE 寫法：

```sql
-- 子查詢：要從裡面往外讀
SELECT AVG(題數) FROM (
    SELECT exam_id, COUNT(*) AS 題數 FROM questions GROUP BY exam_id
) AS t;

-- CTE：由上往下讀，像寫步驟
WITH exam_counts AS (
    SELECT exam_id, COUNT(*) AS 題數 FROM questions GROUP BY exam_id
)
SELECT AVG(題數) FROM exam_counts;
```

## 多個 CTE

用逗號分隔，後面的 CTE 可以使用前面的：

```sql
WITH
step1 AS (SELECT ...),
step2 AS (SELECT ... FROM step1),
step3 AS (SELECT ... FROM step2)
SELECT * FROM step3;
```

複雜的報表 SQL 用這種方式，可以把問題拆成一步一步，每一步都能單獨檢查。

## CTE 可以重複使用

同一個 CTE 在主查詢裡可以用好幾次（子查詢則要重寫好幾遍）：

```sql
WITH stats AS (SELECT exam_id, COUNT(*) AS cnt FROM questions GROUP BY exam_id)
SELECT * FROM stats
WHERE cnt = (SELECT MAX(cnt) FROM stats);
```

## 遞迴 CTE（進階）

`WITH RECURSIVE` 可以讓 CTE **參照自己**，用來處理：
- 階層資料：組織架構、分類樹、留言串（3-5 課的延伸）
- 產生數列：1 到 100、每一天的日期

```sql
WITH RECURSIVE nums(n) AS (
    SELECT 1                           -- 起點（錨點）
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 10   -- 遞迴部分 + 停止條件
)
SELECT n FROM nums;   -- 1, 2, 3, ..., 10
```

結構：
1. **錨點成員**：第一批資料
2. `UNION ALL`
3. **遞迴成員**：用上一輪的結果產生下一輪
4. 某一輪沒有產生新資料時停止

⚠️ 一定要有停止條件，否則會無限迴圈。

> 💼 SQL Server 寫 `WITH` 就好，不用寫 `RECURSIVE`；MySQL 8.0 以上、PostgreSQL、SQLite 要寫 `WITH RECURSIVE`。

## 💼 工作小技巧

- 寫複雜查詢時，先用 CTE 一步一步拆解，每完成一步就 `SELECT * FROM 該步驟` 檢查
- CTE 只在**這一句 SQL** 有效，執行完就消失。要長期重複使用，請建立 **View**（第 9-1 課）
