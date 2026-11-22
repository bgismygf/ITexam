-- =====================================================================
-- 7-1 交易：用 SAVEPOINT 練習（在 DB Browser 中可以直接執行）
-- 建議一句一句執行（Shift+F5），觀察每一步的資料變化
-- =====================================================================

-- 準備：銀行帳戶練習表
DROP TABLE IF EXISTS my_accounts;
CREATE TABLE my_accounts (
    id      TEXT PRIMARY KEY,
    name    TEXT,
    balance INTEGER CHECK (balance >= 0)    -- 餘額不能是負數
);
INSERT INTO my_accounts VALUES ('A', '小明', 5000), ('B', '小華', 3000);

SELECT * FROM my_accounts;

-- ---------------------------------------------------------------------
-- 範例 1：成功的轉帳：小明轉 1000 給小華
-- ---------------------------------------------------------------------
SAVEPOINT transfer1;

UPDATE my_accounts SET balance = balance - 1000 WHERE id = 'A';
UPDATE my_accounts SET balance = balance + 1000 WHERE id = 'B';

SELECT * FROM my_accounts;      -- 小明 4000、小華 4000

RELEASE transfer1;              -- 確認（相當於這一段的 COMMIT）

-- ---------------------------------------------------------------------
-- 範例 2：中途反悔：轉了之後發現轉錯人，ROLLBACK
-- ---------------------------------------------------------------------
SAVEPOINT transfer2;

UPDATE my_accounts SET balance = balance - 2000 WHERE id = 'A';
UPDATE my_accounts SET balance = balance + 2000 WHERE id = 'B';

SELECT * FROM my_accounts;      -- 小明 2000、小華 6000

ROLLBACK TO transfer2;          -- 反悔！回到存檔點

SELECT * FROM my_accounts;      -- 回到小明 4000、小華 4000

RELEASE transfer2;

-- ---------------------------------------------------------------------
-- 範例 3：轉帳失敗：小明餘額不足，第 1 步違反 CHECK 限制
-- ---------------------------------------------------------------------
SAVEPOINT transfer3;

-- 預期錯誤
UPDATE my_accounts SET balance = balance - 9999 WHERE id = 'A';   -- 餘額會變負數，失敗

-- 第 1 步失敗了，第 2 步就不能執行，要整個 ROLLBACK
ROLLBACK TO transfer3;
RELEASE transfer3;

SELECT * FROM my_accounts;      -- 不變

-- ---------------------------------------------------------------------
-- 範例 4：不用交易的危險：第 1 步成功、第 2 步失敗
-- ---------------------------------------------------------------------
UPDATE my_accounts SET balance = balance - 500 WHERE id = 'A';    -- 成功：小明扣 500
UPDATE my_accounts SET balance = balance + 500 WHERE id = 'C';    -- 打錯帳號！這句不會出錯，但帳戶 C 不存在，影響 0 列
SELECT * FROM my_accounts;      -- 小明少了 500，但沒有人收到錢！

-- 💡 重點：UPDATE 找不到資料「不會出錯」，只會影響 0 列。
--    程式中要檢查「影響的列數」，不對就 ROLLBACK。

-- ---------------------------------------------------------------------
-- 一般資料庫的標準寫法（在 DB Browser 中可能會出錯，僅供參考）
-- ---------------------------------------------------------------------
-- BEGIN TRANSACTION;
-- UPDATE my_accounts SET balance = balance - 1000 WHERE id = 'A';
-- UPDATE my_accounts SET balance = balance + 1000 WHERE id = 'B';
-- COMMIT;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：用 SAVEPOINT 把小華的 1500 元轉給小明，確認後 RELEASE


-- 練習 2：在一個 SAVEPOINT 中，先刪除 my_accounts 的所有資料，
--        SELECT 確認都不見了，再 ROLLBACK TO 救回來


-- 練習 3：巢狀存檔點：
--        SAVEPOINT 外層 → 小明 +100 → SAVEPOINT 內層 → 小華 +100
--        → ROLLBACK TO 內層 → 查看結果（小明有加、小華沒加）→ RELEASE 外層


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SAVEPOINT t1;
UPDATE my_accounts SET balance = balance - 1500 WHERE id = 'B';
UPDATE my_accounts SET balance = balance + 1500 WHERE id = 'A';
SELECT * FROM my_accounts;
RELEASE t1;

-- 練習 2
SAVEPOINT t2;
DELETE FROM my_accounts;
SELECT * FROM my_accounts;     -- 空的
ROLLBACK TO t2;
SELECT * FROM my_accounts;     -- 救回來了
RELEASE t2;

-- 練習 3
SAVEPOINT outer_sp;
UPDATE my_accounts SET balance = balance + 100 WHERE id = 'A';
SAVEPOINT inner_sp;
UPDATE my_accounts SET balance = balance + 100 WHERE id = 'B';
ROLLBACK TO inner_sp;
SELECT * FROM my_accounts;     -- 小明 +100，小華不變
RELEASE outer_sp;

*/

DROP TABLE IF EXISTS my_accounts;
