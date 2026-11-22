-- =====================================================================
-- 9-5 SQL Injection：觀察注入後的 SQL 長什麼樣子
-- ⚠️ 只在自己的練習資料庫上做，對他人的系統做這種測試是違法的
-- =====================================================================

-- 準備：使用者帳號表（真實系統的密碼絕對不能存明碼，要用雜湊，這裡只是示範）
DROP TABLE IF EXISTS my_users;
CREATE TABLE my_users (
    user_id  INTEGER PRIMARY KEY,
    username TEXT UNIQUE,
    password TEXT,
    role     TEXT
);
INSERT INTO my_users VALUES
    (1, 'admin', 'S3cret!',  '管理員'),
    (2, 'ming',  '1234',     '一般'),
    (3, 'hua',   'abcd',     '一般');

-- ---------------------------------------------------------------------
-- 正常登入：程式把帳號 ming、密碼 1234 串接進 SQL
-- ---------------------------------------------------------------------
SELECT * FROM my_users WHERE username = 'ming' AND password = '1234';     -- 1 筆

-- 密碼錯誤
SELECT * FROM my_users WHERE username = 'ming' AND password = 'wrong';    -- 0 筆

-- ---------------------------------------------------------------------
-- 攻擊 1：帳號欄輸入  ' OR '1'='1' --
-- 串接後的 SQL 變成下面這樣（注意 -- 後面的密碼檢查變成註解了）
-- ---------------------------------------------------------------------
SELECT * FROM my_users WHERE username = '' OR '1'='1'
-- ' AND password = 'xxx'
;
-- 結果：全部使用者都查出來了

-- ---------------------------------------------------------------------
-- 攻擊 2：帳號欄輸入  admin' --
-- ---------------------------------------------------------------------
SELECT * FROM my_users WHERE username = 'admin'
-- ' AND password = 'xxx'
;
-- 結果：不用密碼就取得 admin 的資料

-- ---------------------------------------------------------------------
-- 攻擊 3：題目搜尋框輸入  ' UNION SELECT username, password FROM my_users --
-- 原本的程式：SELECT question_id, content FROM questions WHERE content LIKE '%輸入%'
-- ---------------------------------------------------------------------
SELECT question_id, content FROM questions WHERE content LIKE '%'
UNION SELECT username, password FROM my_users
-- %'
;
-- 結果：帳號密碼混在搜尋結果裡被顯示出來

-- ---------------------------------------------------------------------
-- 防範：參數化查詢
-- 在 DB Browser 無法示範參數化（要在程式中使用），第 10-1 課會用 Python 實際操作。
-- 參數化的 SQL 長這樣，? 的位置只會被當成「值」：
--   SELECT * FROM my_users WHERE username = ? AND password = ?
-- 就算輸入 ' OR '1'='1' --，資料庫也只會去找「帳號剛好叫做 ' OR '1'='1' --」的使用者
-- ---------------------------------------------------------------------
SELECT * FROM my_users WHERE username = ''' OR ''1''=''1'' --' AND password = 'xxx';
-- 這句模擬參數化的效果：整個輸入被當成一個字串值（單引號被跳脫成兩個），結果 0 筆

DROP TABLE my_users;
