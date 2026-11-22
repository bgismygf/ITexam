# 5-5 ALTER、DROP、TRUNCATE 🎯

## ALTER TABLE：修改表結構

| 動作 | 語法 | SQLite |
|---|---|---|
| 新增欄位 | `ALTER TABLE t ADD COLUMN 欄位 型態;` | ✅ |
| 欄位改名 | `ALTER TABLE t RENAME COLUMN 舊名 TO 新名;` | ✅（3.25+） |
| 刪除欄位 | `ALTER TABLE t DROP COLUMN 欄位;` | ✅（3.35+） |
| 表改名 | `ALTER TABLE t RENAME TO 新表名;` | ✅ |
| 修改欄位型態 | `ALTER TABLE t ALTER COLUMN 欄位 新型態;`（SQL Server）<br>`ALTER TABLE t MODIFY 欄位 新型態;`（MySQL、Oracle） | ❌ 不支援 |
| 新增 / 刪除限制條件 | `ALTER TABLE t ADD CONSTRAINT ...;` | ❌ 不支援 |

> SQLite 的 ALTER 功能比較少。不支援的修改，要「建新表 → 複製資料 → 刪舊表 → 新表改名」。
> DB Browser 的 **Modify Table** 功能會自動幫你做這些步驟。

💼 **正式環境修改表結構要很小心**：
- 大表加欄位、改型態，可能鎖住整張表很久，影響線上服務
- 刪除欄位前，確認沒有程式在使用
- 結構變更要寫成腳本保存（稱為 **migration**），才能在測試環境和正式環境重複執行

## DROP：刪除物件

```sql
DROP TABLE 資料表;              -- 刪除整張表（結構＋資料）
DROP TABLE IF EXISTS 資料表;    -- 不存在也不會出錯
DROP INDEX 索引名稱;
DROP VIEW 檢視表名稱;
```

## TRUNCATE：清空資料表

```sql
TRUNCATE TABLE 資料表;
```
刪除全部資料，但保留表結構。

> ⚠️ SQLite **沒有 TRUNCATE**，用 `DELETE FROM 資料表;`（不加 WHERE）代替，
> SQLite 會自動最佳化成快速清空。

## 🎯 DELETE vs TRUNCATE vs DROP（必考）

| | DELETE | TRUNCATE | DROP |
|---|---|---|---|
| 分類 | **DML** | **DDL** | **DDL** |
| 刪除什麼 | 資料（可以只刪部分） | **全部**資料 | 資料＋**表結構** |
| 可以加 WHERE | ✅ | ❌ | ❌ |
| 表還在嗎 | ✅ | ✅ | ❌ |
| 速度 | 慢（逐列刪除、逐列記錄 log） | **快**（直接釋放資料頁） | 快 |
| 可以 ROLLBACK | ✅ | 依資料庫而定（Oracle、MySQL 不行） | 依資料庫而定 |
| 觸發 DELETE Trigger | ✅ | ❌ | ❌ |
| 自動編號 | 不重設 | **重設**回起始值 | （表都沒了） |

💡 **記法**：
- DELETE：用橡皮擦一筆一筆擦（可以只擦幾筆，擦錯可以復原）
- TRUNCATE：把整本筆記內頁撕掉，封面留著
- DROP：整本筆記丟掉

## 小測驗

1. 下列關於 TRUNCATE 與 DELETE 的比較，何者錯誤？
   (A) TRUNCATE 屬於 DDL，DELETE 屬於 DML
   (B) TRUNCATE 通常比 DELETE 快
   (C) TRUNCATE 可以搭配 WHERE 刪除部分資料
   (D) DROP 會連同表結構一起刪除

2. 要在 emp 表中新增一個 email 欄位，應使用？
   (A) `UPDATE emp ADD email VARCHAR(100);`
   (B) `ALTER TABLE emp ADD email VARCHAR(100);`
   (C) `INSERT INTO emp COLUMN email;`
   (D) `CREATE COLUMN email ON emp;`

<details>
<summary>看答案</summary>

1. **(C)**
2. **(B)**
</details>
