# 2-4 SQL 的執行順序 🎯💼

## 觀念

SQL 的**書寫順序**和**執行順序**不一樣。搞懂執行順序，很多「為什麼這樣寫會錯」的問題就迎刃而解。

## 書寫順序 vs 執行順序

| 書寫順序 | 子句 | 執行順序 |
|:-:|---|:-:|
| 1 | `SELECT` | **5** |
| 2 | `FROM` | **1** |
| 3 | `WHERE` | **2** |
| 4 | `GROUP BY` | **3** |
| 5 | `HAVING` | **4** |
| 6 | `ORDER BY` | **6** |
| 7 | `LIMIT` | **7** |

### 🎯 執行順序（背起來）

```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

💡 **口訣**：「**從哪**拿（FROM）→ **篩**列（WHERE）→ **分**組（GROUP BY）→ **篩**組（HAVING）→ **選**欄（SELECT）→ **排**序（ORDER BY）→ **取**幾筆（LIMIT）」

## 用一個例子跑一遍

```sql
SELECT exam_id, COUNT(*) AS 題數
FROM questions
WHERE score = 2
GROUP BY exam_id
HAVING COUNT(*) >= 6
ORDER BY 題數 DESC
LIMIT 2;
```

| 步驟 | 動作 | 剩下的資料 |
|---|---|---|
| 1. FROM | 拿出 questions 全部 30 列 | 30 列 |
| 2. WHERE | 只留 score = 2 的列 | 24 列（第 1 份考試的 6 題被排除） |
| 3. GROUP BY | 依 exam_id 分組 | 4 組（exam 2、3、4、5） |
| 4. HAVING | 只留題數 ≥ 6 的組 | 3 組（exam 2、3、4） |
| 5. SELECT | 計算要顯示的欄位，建立別名「題數」 | 3 列 |
| 6. ORDER BY | 依題數由大到小 | 3 列（exam 2 排第一） |
| 7. LIMIT | 取前 2 筆 | 2 列 |

## 用執行順序解釋常見問題

| 問題 | 原因 |
|---|---|
| WHERE 不能用彙總函數 | WHERE（2）在 GROUP BY（3）之前，還沒分組 |
| WHERE 不能用 SELECT 的別名 | WHERE（2）在 SELECT（5）之前，別名還不存在 |
| ORDER BY 可以用別名 | ORDER BY（6）在 SELECT（5）之後，別名已經存在 |
| HAVING 標準上不能用別名 | HAVING（4）在 SELECT（5）之前 |
| GROUP BY 後 SELECT 只能放分組欄位和彙總 | SELECT（5）在 GROUP BY（3）之後，此時每組只剩一列 |

> SQLite 和 MySQL 比較寬鬆，允許在 WHERE、GROUP BY、HAVING 使用別名，
> 但這不是標準，換到 SQL Server 或 Oracle 就會出錯。

⚠️ 這是**邏輯上**的執行順序。資料庫實際執行時會做最佳化（例如先用索引），
但結果一定跟這個邏輯順序一致。

## 單元總整理

```sql
SELECT   欄位, 彙總函數      -- 5. 選欄
FROM     資料表               -- 1. 從哪拿
WHERE    列的條件            -- 2. 篩列（不能用彙總）
GROUP BY 分組欄位             -- 3. 分組
HAVING   組的條件            -- 4. 篩組（可以用彙總）
ORDER BY 排序欄位             -- 6. 排序
LIMIT    筆數;                -- 7. 取幾筆
```

## 小測驗

1. SQL 查詢語句中，下列子句的邏輯執行順序何者正確？
   (A) SELECT → FROM → WHERE → GROUP BY
   (B) FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
   (C) FROM → SELECT → WHERE → ORDER BY
   (D) WHERE → FROM → GROUP BY → SELECT

2. 為什麼 ORDER BY 可以使用 SELECT 中定義的欄位別名？
   (A) ORDER BY 在 SELECT 之後執行
   (B) ORDER BY 在 SELECT 之前執行
   (C) 別名是全域變數
   (D) 其實不行

<details>
<summary>看答案</summary>

1. **(B)**
2. **(A)**
</details>
