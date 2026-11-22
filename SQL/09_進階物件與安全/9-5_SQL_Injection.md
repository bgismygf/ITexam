# 9-5 SQL Injection 原理與防範 🎯💼

> 資料庫課程和**資通安全類**考試都很常考。也是真實世界中最常見、危害最大的網站漏洞之一
> （長年名列 OWASP Top 10）。

## 觀念

**SQL 注入（SQL Injection）**：攻擊者在**輸入欄位**中填入 SQL 語法，
如果程式直接把輸入**串接**到 SQL 字串中，攻擊者的語法就會被資料庫執行。

## 原理

### 有漏洞的程式（Python 範例）

```python
username = input("帳號：")
password = input("密碼：")

sql = "SELECT * FROM users WHERE username = '" + username + \
      "' AND password = '" + password + "'"
```

### 正常輸入

帳號 `ming`、密碼 `1234`：
```sql
SELECT * FROM users WHERE username = 'ming' AND password = '1234'
```

### 攻擊 1：繞過登入

帳號輸入 `' OR '1'='1' --`，密碼隨便打：
```sql
SELECT * FROM users WHERE username = '' OR '1'='1' --' AND password = 'xxx'
```
- `'` 提早結束了字串
- `OR '1'='1'` 永遠成立 → 查出**所有使用者**
- `--` 讓後面的密碼檢查變成**註解**

結果：**不用密碼就登入了**（通常會以第一個使用者，也就是管理員的身分登入）。

### 攻擊 2：竊取其他資料

搜尋框輸入 `' UNION SELECT username, password FROM users --`：
```sql
SELECT title, content FROM articles WHERE title LIKE '%'
UNION SELECT username, password FROM users --%'
```
所有帳號密碼都顯示在搜尋結果裡。（這就是 3-6 課的 UNION）

### 攻擊 3：破壞資料

輸入 `'; DROP TABLE users; --`：
```sql
SELECT * FROM users WHERE username = ''; DROP TABLE users; --'
```
如果資料庫允許一次執行多句 SQL，整張表就被刪除了。

## 🎯 防範方法

### ✅ 1. 參數化查詢（Parameterized Query / Prepared Statement）——**最重要**

**不要串接字串**，用「佔位符」，把 SQL 結構和資料分開送給資料庫：

```python
# Python + SQLite
sql = "SELECT * FROM users WHERE username = ? AND password = ?"
cursor.execute(sql, (username, password))
```

```csharp
// C# + SQL Server
var cmd = new SqlCommand("SELECT * FROM users WHERE username = @u AND password = @p", conn);
cmd.Parameters.AddWithValue("@u", username);
cmd.Parameters.AddWithValue("@p", password);
```

```java
// Java
PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE username = ? AND password = ?");
ps.setString(1, username);
ps.setString(2, password);
```

**原理**：資料庫先解析 SQL 的**結構**，參數只會被當成「**值**」，
不管裡面有什麼引號、分號、關鍵字，都**不會被當成 SQL 語法執行**。

第 10-1 課會用 Python 實際操作。

### ✅ 2. 其他防護措施（縱深防禦）

| 措施 | 說明 |
|---|---|
| **最小權限** | 應用程式的資料庫帳號不要有 DROP、管理員權限（9-4 課） |
| **輸入驗證** | 檢查格式（例如學號只能是英數字、長度限制），用**白名單**而不是黑名單 |
| **預存程序** | 參數化的預存程序也能防止注入（但預存程序裡如果又串接字串執行，一樣有漏洞） |
| **使用 ORM 框架** | 例如 Entity Framework、Hibernate、Django ORM，預設使用參數化查詢 |
| **錯誤訊息不要外露** | 不要把資料庫錯誤直接顯示給使用者，攻擊者會利用錯誤訊息推測資料表結構 |
| **WAF**（網頁應用程式防火牆） | 過濾常見的攻擊字串，但只是輔助，不能取代參數化查詢 |

### ❌ 不夠安全的做法

| 做法 | 為什麼不夠 |
|---|---|
| 自己把 `'` 取代成 `''` | 容易漏掉其他情況（例如編碼繞過、數字欄位不需要引號） |
| 黑名單過濾關鍵字（擋 `DROP`、`OR`） | 可以用大小寫混合、註解、編碼等方式繞過；也會誤擋正常輸入 |
| 只在前端（JavaScript）驗證 | 攻擊者可以直接送請求給伺服器，完全繞過前端 |

## 小測驗

1. 防範 SQL Injection 最有效的方法是？
   (A) 使用 HTTPS 加密傳輸
   (B) 使用參數化查詢
   (C) 在前端用 JavaScript 驗證輸入
   (D) 隱藏資料庫的 IP 位址

2. 攻擊者在登入帳號欄輸入 `admin' --`，其目的最可能是？
   (A) 刪除 admin 帳號
   (B) 讓密碼檢查的條件變成註解，以 admin 身分登入
   (C) 新增一個 admin 帳號
   (D) 造成資料庫當機

<details>
<summary>看答案</summary>

1. **(B)**
2. **(B)**
</details>
