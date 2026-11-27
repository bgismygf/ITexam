# 1-6 NULL 與三值邏輯 🎯

NULL 是 SQL 裡最容易出錯的觀念，也是考試愛考的陷阱。

## NULL 是什麼

**NULL 代表「未知」或「不適用」**，不是 0，也不是空字串 `''`。

例如題庫第 29 題的 `answer` 是 NULL，意思是「答案還不知道」。

## 規則 1：NULL 參與運算，結果都是 NULL

```sql
SELECT NULL + 1;      -- NULL
SELECT NULL * 0;      -- NULL
SELECT 'A' || NULL;   -- NULL（文字串接也一樣）
```

（例外：Oracle 的 `||` 會把 NULL 當成空字串，結果是 `'A'`，見 1-1 課。）

想像成：「一個不知道的數字加 1」，結果還是「不知道」。

## 規則 2：NULL 參與比較，結果是 UNKNOWN

SQL 的邏輯不是只有 TRUE 和 FALSE，而是有**三個值**：

| 值 | 意思 |
|---|---|
| TRUE | 成立 |
| FALSE | 不成立 |
| **UNKNOWN** | 不知道（只要跟 NULL 比較就會出現） |

```sql
NULL = 1       -- UNKNOWN
NULL = NULL    -- UNKNOWN（兩個未知不一定相等！）
NULL <> 1      -- UNKNOWN
```

### ⭐ WHERE 只保留 TRUE 的列

**FALSE 和 UNKNOWN 的列都會被排除。** 這就是為什麼：

```sql
WHERE answer = NULL      -- 永遠是 UNKNOWN，查不到資料
WHERE answer IS NULL     -- ✅ 正確
WHERE answer <> 'A'      -- 第 29 題不會出現（NULL <> 'A' 是 UNKNOWN）
```

## 🎯 三值邏輯真值表（必考）

### AND：有 FALSE 就是 FALSE

| AND | TRUE | FALSE | UNKNOWN |
|---|---|---|---|
| **TRUE** | TRUE | FALSE | UNKNOWN |
| **FALSE** | FALSE | FALSE | FALSE |
| **UNKNOWN** | UNKNOWN | FALSE | UNKNOWN |

### OR：有 TRUE 就是 TRUE

| OR | TRUE | FALSE | UNKNOWN |
|---|---|---|---|
| **TRUE** | TRUE | TRUE | TRUE |
| **FALSE** | TRUE | FALSE | UNKNOWN |
| **UNKNOWN** | TRUE | UNKNOWN | UNKNOWN |

### NOT

| x | NOT x |
|---|---|
| TRUE | FALSE |
| FALSE | TRUE |
| UNKNOWN | UNKNOWN |

💡 **記法**：把 UNKNOWN 想成「可能是 TRUE，也可能是 FALSE」：
- `FALSE AND ?`：不管 ? 是什麼，一定是 FALSE
- `TRUE OR ?`：不管 ? 是什麼，一定是 TRUE
- 其他情況答案取決於 ?，所以是 UNKNOWN

## 處理 NULL 的工具

### COALESCE：遇到 NULL 時用替代值

```sql
SELECT COALESCE(answer, '未輸入') FROM questions;
-- answer 有值就顯示原值，NULL 就顯示「未輸入」
```

`COALESCE(a, b, c, ...)` 會回傳**第一個不是 NULL** 的值。這是標準 SQL，各家資料庫都支援。

💼 各家也有自己的函數：SQLite / MySQL 的 `IFNULL()`、SQL Server 的 `ISNULL()`、Oracle 的 `NVL()`，
功能類似，但建議用 `COALESCE`，換資料庫也能用。

### NULLIF：兩值相等時回傳 NULL

```sql
SELECT NULLIF(a, b);   -- a = b 時回傳 NULL，否則回傳 a
```
常用來避免除以 0：`total / NULLIF(count, 0)`

## 預告：NULL 在其他地方的行為

| 情境 | NULL 的處理 | 在哪一課 |
|---|---|---|
| `COUNT(*)` | 算進去 | 2-1 |
| `COUNT(欄位)`、`SUM`、`AVG` | **忽略 NULL** | 2-1 |
| `GROUP BY` | 所有 NULL 分在同一組 | 2-2 |
| `NOT IN` 清單中有 NULL | 結果變成空的 | 4-2 |
| `UNIQUE` 限制 | 大部分資料庫允許多個 NULL | 5-3 |
| `PRIMARY KEY` | 不允許 NULL | 5-3 |

## 小測驗

1. 在 SQL 三值邏輯中，`UNKNOWN OR TRUE` 的結果是？
   (A) TRUE (B) FALSE (C) UNKNOWN (D) NULL

2. `UNKNOWN AND TRUE` 的結果是？
   (A) TRUE (B) FALSE (C) UNKNOWN (D) 語法錯誤

3. 資料表 T 的欄位 x 的值為 1、2、NULL。執行 `SELECT * FROM T WHERE x <> 1;` 會回傳幾筆？
   (A) 0 (B) 1 (C) 2 (D) 3

<details>
<summary>看答案</summary>

1. **(A)** 有 TRUE 就是 TRUE
2. **(C)** 結果取決於 UNKNOWN 的實際值
3. **(B)** 只有 x = 2 那筆。`NULL <> 1` 是 UNKNOWN，會被排除
</details>
