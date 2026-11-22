# 5-2 CREATE TABLE 與資料型態 🎯💼

## 語法

```sql
CREATE TABLE 資料表名稱 (
    欄位名稱1  資料型態  [限制條件],
    欄位名稱2  資料型態  [限制條件],
    ...
);
```

範例：建立一張「讀書筆記」表
```sql
CREATE TABLE my_notes (
    note_id    INTEGER PRIMARY KEY,
    title      TEXT NOT NULL,
    content    TEXT,
    created_at TEXT DEFAULT (datetime('now', 'localtime'))
);
```

限制條件（`PRIMARY KEY`、`NOT NULL`、`DEFAULT` 等）下一課會詳細說明。

## 常用寫法

| 寫法 | 作用 |
|---|---|
| `CREATE TABLE IF NOT EXISTS t (...)` | 表已存在時不會出錯（跳過） |
| `DROP TABLE IF EXISTS t` | 表不存在時不會出錯 |
| `CREATE TABLE t AS SELECT ...` | 用查詢結果**建立新表並複製資料**（不會複製主鍵、限制條件） |

💼 `CREATE TABLE 備份表 AS SELECT * FROM 原表;` 是修改資料前**快速備份**的常用技巧。
（SQL Server 的寫法是 `SELECT * INTO 備份表 FROM 原表;`）

## 資料型態選擇

### SQLite 的型態（彈性很大）

SQLite 只有 5 種儲存類型：`INTEGER`、`REAL`、`TEXT`、`BLOB`、`NULL`。
而且 SQLite **不會嚴格檢查型態**，在 INTEGER 欄位存文字也不會出錯（除非使用 `STRICT` 資料表）。
這是 SQLite 的特例，其他資料庫都會嚴格檢查。

### 💼 一般資料庫的型態選擇原則

| 資料 | 建議型態 | 原因 |
|---|---|---|
| 編號、數量 | `INT` / `BIGINT` | 資料量可能超過 21 億時用 BIGINT |
| **金額** | **`DECIMAL(p, s)`** | `FLOAT` / `REAL` 有誤差（0.1 + 0.2 ≠ 0.3） |
| 身分證、郵遞區號、電話 | `CHAR` / `VARCHAR` | 雖然是數字，但不會拿來計算，而且可能有開頭的 0 |
| 姓名、標題 | `VARCHAR(n)` / `NVARCHAR(n)` | 長度不固定 |
| 長文章 | `TEXT` / `NVARCHAR(MAX)` | |
| 日期 | `DATE` | 不要用文字存日期（SQLite 例外） |
| 日期時間 | `DATETIME` / `TIMESTAMP` | |
| 是否 | `BOOLEAN` / `BIT` | MySQL 用 `TINYINT(1)` |

🎯 `DECIMAL(p, s)`：p 是**總位數**，s 是**小數位數**。
`DECIMAL(5, 2)` 可以存 -999.99 ～ 999.99。

## 命名規則（💼 工作慣例）

- 用英文、小寫、底線分隔：`exam_id`、`created_at`（snake_case）
- 避免用保留字當名稱：`order`、`user`、`select`、`group`（真的要用，要加引號）
- 表名用複數或單數，**整個專案統一**就好
- 主鍵常命名為 `id` 或 `表名_id`
- 常見的通用欄位：`created_at`（建立時間）、`updated_at`（更新時間）

## 小測驗

1. 要儲存商品價格（最多到 99999.99），最適合的型態為？
   (A) FLOAT (B) INT (C) DECIMAL(7, 2) (D) VARCHAR(7)

2. 身分證字號最適合使用哪一種型態？
   (A) INT (B) CHAR(10) (C) DECIMAL(10) (D) FLOAT

<details>
<summary>看答案</summary>

1. **(C)**。總共 7 位，小數 2 位
2. **(B)**。固定 10 碼，含英文字母
</details>
