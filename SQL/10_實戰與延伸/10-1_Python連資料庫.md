# 10-1 用 Python 連資料庫、參數化查詢 💼

## 觀念

到目前為止，我們都是在 DB Browser 裡**手動**執行 SQL。
實際工作中，SQL 大多是**由程式執行**的：網頁、App、自動化報表、資料處理腳本。

```
使用者 → 網頁 / App → 程式（Python、C#、Java…）→ SQL → 資料庫
```

本課用 **Python** 示範，因為：
- 語法簡單，適合入門
- 內建 `sqlite3` 模組，**不用安裝任何套件**
- 資料分析、自動化、AI 領域都大量使用

你的電腦已經裝好 Python 了（Python 3.14）。

## 基本流程（所有語言、所有資料庫都一樣）

```
1. 連線（connect）
2. 執行 SQL（execute）
3. 取得結果（fetch）
4. 提交或回復（commit / rollback）← 有修改資料時
5. 關閉連線（close）
```

## Python + SQLite 範例

```python
import sqlite3

conn = sqlite3.connect("data/exam.db")      # 1. 連線
cur = conn.cursor()

cur.execute("SELECT year, subject FROM exams WHERE year = ?", (113,))   # 2. 執行（參數化）
for row in cur.fetchall():                  # 3. 取得結果
    print(row)

conn.close()                                # 5. 關閉
```

## ⭐ 參數化查詢（9-5 課的實作）

```python
year = input("請輸入年度：")

# ❌ 危險：字串串接，有 SQL Injection 漏洞
cur.execute("SELECT * FROM exams WHERE year = " + year)
cur.execute(f"SELECT * FROM exams WHERE year = {year}")

# ✅ 安全：參數化查詢
cur.execute("SELECT * FROM exams WHERE year = ?", (year,))
```

⚠️ 參數只有一個時，要寫成 `(year,)`，**逗號不能省略**（這樣才是 tuple）。

### 不同資料庫套件的佔位符

| 套件 | 資料庫 | 佔位符 |
|---|---|---|
| `sqlite3` | SQLite | `?` 或 `:name` |
| `pyodbc` | SQL Server 等 | `?` |
| `pymysql` / `mysql-connector` | MySQL | `%s` |
| `psycopg` | PostgreSQL | `%s` |
| `oracledb` | Oracle | `:1` 或 `:name` |

⚠️ `%s` 是佔位符，**不是** Python 的字串格式化，不要寫成 `"... %s" % value`。

## 交易處理

```python
try:
    cur.execute("UPDATE accounts SET balance = balance - ? WHERE id = ?", (1000, 'A'))
    cur.execute("UPDATE accounts SET balance = balance + ? WHERE id = ?", (1000, 'B'))
    conn.commit()        # 全部成功才提交
except Exception:
    conn.rollback()      # 有任何錯誤就回復
    raise
```

更簡潔的寫法：`with conn:` 區塊結束時自動 commit，發生例外時自動 rollback。

## 練習

執行 [`10-1_Python連資料庫.py`](10-1_Python連資料庫.py)：

在 VS Code 打開這個檔案，按右上角的 ▶ 執行；或在終端機輸入：
```
python "10_實戰與延伸/10-1_Python連資料庫.py"
```

程式會示範：查詢、參數化查詢、SQL Injection 的差別、交易、把結果轉成字典。

## 💼 其他語言連資料庫

| 語言 | 常用方式 |
|---|---|
| C# / .NET | ADO.NET（`SqlConnection`）、Dapper、Entity Framework |
| Java | JDBC、MyBatis、Hibernate / JPA |
| JavaScript（Node.js） | `mysql2`、`pg`、Prisma、Sequelize |
| PHP | PDO |

**ORM**（物件關聯對映，例如 Entity Framework、Hibernate）可以用物件的方式操作資料庫，
不用直接寫 SQL。但 ORM 產生的 SQL 不一定有效率，**懂 SQL 才能看懂和調校 ORM 的行為**。
