# 1-4 ORDER BY 與 LIMIT 💼

## ORDER BY：排序

```sql
SELECT 欄位 FROM 資料表
WHERE 條件
ORDER BY 欄位 [ASC | DESC];
```

| 關鍵字 | 意思 | 說明 |
|---|---|---|
| `ASC` | 遞增（小 → 大） | **預設值**，可以省略 |
| `DESC` | 遞減（大 → 小） | 必須寫出來 |

```sql
SELECT * FROM exams ORDER BY year;        -- 年度由舊到新
SELECT * FROM exams ORDER BY year DESC;   -- 年度由新到舊
```

### 多欄位排序

先依第一個欄位排，相同時再依第二個欄位排：
```sql
ORDER BY year DESC, subject ASC
-- 先依年度由新到舊；同一年再依科目排
```
⚠️ `DESC` 只作用在它**前面那一個**欄位，不是全部欄位。

#### 一步一步看

題庫的 `exams` 表（只看 exam_id、year、subject）：

| exam_id | year | subject |
|---|---|---|
| 1 | 110 | 計算機原理 |
| 2 | 111 | 計算機原理 |
| 3 | 112 | 網路概論 |
| 4 | 113 | 計算機原理 |
| 5 | 113 | 網路概論 |

```sql
SELECT exam_id, year, subject FROM exams
ORDER BY year DESC, subject ASC;
```

**第 1 步：先看 `year DESC`**，年度由大到小：113、113、112、111、110。
兩筆 113 年度相同，誰在前面還沒決定。

**第 2 步：年度相同的，再看 `subject ASC`**，科目由小到大。
「網」的編碼（U+7DB2）比「計」（U+8A08）小，所以網路概論在前面：

| exam_id | year | subject |
|---|---|---|
| 5 | 113 | 網路概論 |
| 4 | 113 | 計算機原理 |
| 3 | 112 | 網路概論 |
| 2 | 111 | 計算機原理 |
| 1 | 110 | 計算機原理 |

重點：
- **第二個欄位只用來「破平手」**：只有第一個欄位相同時才會用到。上例只有 113 年有兩筆，所以 `subject ASC` 只影響這兩筆的順序
- **每個欄位的方向各自獨立**：年度由大到小，同時科目由小到大，互不影響
- **`ASC` 可以省略**：`ORDER BY year DESC, subject` 結果完全一樣

#### ⚠️ 常見誤解：以為一個 DESC 會作用在全部欄位

```sql
ORDER BY year, subject DESC
--       └ 沒寫，預設 ASC ┘   └ 只有 subject 是 DESC ┘
```

這句的意思是「年度由**小**到大；同一年，科目由大到小」，**不是**「兩個都由大到小」。
想讓兩個欄位都由大到小，每個欄位後面都要寫：`ORDER BY year DESC, subject DESC`。

💡 **生活例子**：成績排名「總分高的在前，總分一樣的依座號」＝ `ORDER BY 總分 DESC, 座號 ASC`。

### 排序規則

- 數字：依大小
- 文字：依字元編碼。英文依字母順序；中文的順序不一定是筆畫或注音，要看資料庫的設定（collation）
- NULL：SQLite 和 MySQL 把 NULL 當成**最小**；PostgreSQL 和 Oracle 當成**最大**

### 🎯 重點：沒有 ORDER BY，順序就沒有保證

關聯式資料表的「列沒有順序」（0-4 課）。你看到資料好像照順序排，只是剛好而已。
**需要特定順序，就一定要寫 ORDER BY。**

## LIMIT：限制筆數

```sql
SELECT * FROM questions
ORDER BY score DESC
LIMIT 5;          -- 只取前 5 筆
```

搭配 `OFFSET` 可以跳過前幾筆，常用來做**分頁**：
```sql
LIMIT 10 OFFSET 20   -- 跳過前 20 筆，取 10 筆（第 3 頁，每頁 10 筆）
```

### 💼 不同資料庫的寫法

| 資料庫 | 前 5 筆 | 第 3 頁（每頁 10 筆） |
|---|---|---|
| SQLite / MySQL / PostgreSQL | `LIMIT 5` | `LIMIT 10 OFFSET 20` |
| SQL Server | `SELECT TOP 5 ...` | `ORDER BY ... OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY` |
| Oracle 12c+ | `FETCH FIRST 5 ROWS ONLY` | `OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY` |

## 💼 工作小技巧

- **LIMIT 一定要搭配 ORDER BY**，不然每次取到的「前 5 筆」可能都不一樣
- 臨時查看大資料表時，養成加 `LIMIT 100` 的習慣，避免一次撈出幾百萬筆把工具卡住
- `ORDER BY` 可以用 SELECT 裡的別名（1-5 課）或計算結果排序

## 小測驗

1. `ORDER BY year DESC, score` 的排序方式是？
   (A) 年度和配分都由大到小
   (B) 年度由大到小，同年度再依配分由小到大
   (C) 年度由小到大，同年度再依配分由大到小
   (D) 只依年度排序

2. 沒有寫 ORDER BY 的查詢結果，順序為何？
   (A) 依主鍵由小到大 (B) 依新增時間 (C) 不保證任何順序 (D) 依第一個欄位排序

<details>
<summary>看答案</summary>

1. **(B)** DESC 只作用在 year，score 用預設的 ASC
2. **(C)** 不保證順序
</details>
