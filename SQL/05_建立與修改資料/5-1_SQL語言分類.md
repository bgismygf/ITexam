# 5-1 SQL 語言分類：DDL / DML / DCL / TCL 🎯

> 本課只有觀念，沒有練習檔。這是**考試非常常考**的題型。

## 四大類

| 分類 | 全名 | 中文 | 作用 | 指令 |
|---|---|---|---|---|
| **DDL** | Data **Definition** Language | 資料**定義**語言 | 定義、修改**結構**（表、索引、檢視表） | `CREATE`、`ALTER`、`DROP`、`TRUNCATE` |
| **DML** | Data **Manipulation** Language | 資料**操作**語言 | 操作表裡的**資料** | `SELECT`、`INSERT`、`UPDATE`、`DELETE` |
| **DCL** | Data **Control** Language | 資料**控制**語言 | 控制**權限** | `GRANT`、`REVOKE` |
| **TCL** | **Transaction** Control Language | **交易**控制語言 | 控制**交易** | `COMMIT`、`ROLLBACK`、`SAVEPOINT` |

有些教科書會再把 `SELECT` 獨立出來，稱為 **DQL（Data Query Language，資料查詢語言）**。
考試時如果選項沒有 DQL，`SELECT` 就屬於 **DML**。

## 💡 記憶方法

- **DDL** → **D**efinition → 蓋房子、改格局、拆房子（**結構**）
  - CREATE 蓋、ALTER 改、DROP 拆、TRUNCATE 清空（但房子留著）
- **DML** → **M**anipulation → 搬家具進出（**資料**）
  - INSERT 搬進、UPDATE 換、DELETE 搬出、SELECT 看
- **DCL** → **C**ontrol → 發鑰匙、收鑰匙（**權限**）
  - GRANT 給、REVOKE 收回
- **TCL** → **T**ransaction → 存檔、讀檔（**交易**）
  - COMMIT 確認、ROLLBACK 復原

## 🎯 容易混淆的地方

### 1. 名稱相似的指令

| 結構（DDL） | 資料（DML） |
|---|---|
| `CREATE` 建立表 | `INSERT` 新增資料 |
| `ALTER` 修改表結構 | `UPDATE` 修改資料 |
| `DROP` 刪除表 | `DELETE` 刪除資料 |

⚠️ **`ALTER` vs `UPDATE`**：ALTER 改「表的結構」（例如加一個欄位），UPDATE 改「表裡的資料」。
⚠️ **`DROP` vs `DELETE`**：DROP 把整張表（含結構）刪掉，DELETE 只刪資料、表還在。

### 2. TRUNCATE 是 DDL，不是 DML

雖然 TRUNCATE 的效果是「清空資料」，但它屬於 **DDL**。5-5 課會比較 DELETE / TRUNCATE / DROP。

### 3. DDL 通常會自動 COMMIT

在 Oracle、MySQL 中，執行 DDL 會**自動提交**目前的交易，無法 ROLLBACK。
（SQL Server、PostgreSQL、SQLite 的 DDL 則可以包在交易裡 ROLLBACK）

## 小測驗

1. 下列何者屬於 DDL？
   (A) INSERT (B) UPDATE (C) ALTER (D) GRANT

2. 下列何者屬於 DCL？
   (A) COMMIT (B) REVOKE (C) DELETE (D) DROP

3. 要修改資料表中某一筆資料的值，應使用？
   (A) ALTER (B) UPDATE (C) MODIFY (D) CHANGE

4. TRUNCATE 屬於哪一類？
   (A) DDL (B) DML (C) DCL (D) TCL

<details>
<summary>看答案</summary>

1. **(C)**
2. **(B)**
3. **(B)**
4. **(A)**
</details>
