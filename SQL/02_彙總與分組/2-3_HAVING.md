# 2-3 HAVING 與 WHERE 的差別 🎯

## 觀念

`HAVING` 用來**篩選分組後的結果**。

想查「題數超過 5 題的考試」：
```sql
SELECT exam_id, COUNT(*) AS 題數
FROM questions
GROUP BY exam_id
HAVING COUNT(*) > 5;
```

## 🎯 WHERE 和 HAVING 的差別（必考）

| | WHERE | HAVING |
|---|---|---|
| 篩選的對象 | **每一列**（分組前） | **每一組**（分組後） |
| 執行時機 | GROUP BY **之前** | GROUP BY **之後** |
| 能不能用彙總函數 | ❌ **不行** | ✅ 可以 |
| 一定要搭配 GROUP BY 嗎 | 不用 | 通常搭配（沒有 GROUP BY 時，整張表當成一組） |

```
原始資料 ──WHERE篩選列──▶ 剩下的列 ──GROUP BY──▶ 各組 ──HAVING篩選組──▶ 結果
```

### 為什麼 WHERE 不能用彙總函數

```sql
-- ❌ 錯誤
SELECT exam_id, COUNT(*) FROM questions
WHERE COUNT(*) > 5
GROUP BY exam_id;
```
WHERE 執行的時候還沒分組，一次只看**一列**，「一列的 COUNT」沒有意義。

## 兩者一起用

```sql
SELECT exam_id, COUNT(*) AS 題數
FROM questions
WHERE score = 2              -- 先排除不是 2 分的題目（篩列）
GROUP BY exam_id
HAVING COUNT(*) >= 6;        -- 再留下 2 分題目有 6 題以上的考試（篩組）
```

## 💼 效能小技巧

能用 WHERE 篩選的條件，就**不要放到 HAVING**：

```sql
-- 比較慢：先把所有考試都分組計算，再丟掉不要的
SELECT exam_id, COUNT(*) FROM questions
GROUP BY exam_id
HAVING exam_id IN (1, 2);

-- 比較快：先篩掉不要的資料，再分組
SELECT exam_id, COUNT(*) FROM questions
WHERE exam_id IN (1, 2)
GROUP BY exam_id;
```

**判斷原則**：條件裡**有彙總函數**才放 HAVING，其他都放 WHERE。

## 💼 實用範例：找出重複資料

工作上很常用 `GROUP BY ... HAVING COUNT(*) > 1` 找重複資料：

```sql
-- 找出被作答超過一次的題目
SELECT question_id, COUNT(*)
FROM practice_log
GROUP BY question_id
HAVING COUNT(*) > 1;
```

## 小測驗

1. 下列關於 WHERE 與 HAVING 的敘述，何者錯誤？
   (A) WHERE 在 GROUP BY 之前執行
   (B) HAVING 可以使用彙總函數
   (C) WHERE 可以使用彙總函數
   (D) HAVING 用來篩選分組後的結果

2. 要查詢「員工人數超過 10 人的部門」，條件應放在？
   (A) WHERE COUNT(*) > 10 (B) HAVING COUNT(*) > 10
   (C) ORDER BY COUNT(*) > 10 (D) GROUP BY COUNT(*) > 10

<details>
<summary>看答案</summary>

1. **(C)**
2. **(B)**
</details>
