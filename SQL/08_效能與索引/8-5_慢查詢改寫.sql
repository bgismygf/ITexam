-- =====================================================================
-- 8-5 常見慢查詢寫法與改寫：用 EXPLAIN 和執行時間比較
-- =====================================================================

-- 準備：產生 20 萬筆資料並建立索引
DROP TABLE IF EXISTS my_big_log;
CREATE TABLE my_big_log (
    log_id INTEGER PRIMARY KEY, question_id INTEGER, answered_at TEXT,
    chosen TEXT, is_correct INTEGER, user_name TEXT
);
INSERT INTO my_big_log (question_id, answered_at, chosen, is_correct, user_name)
WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 200000)
SELECT abs(random()) % 30 + 1, datetime('2025-01-01', '+' || (i * 2) || ' minutes'),
       char(65 + abs(random()) % 4), abs(random()) % 2, 'user' || (abs(random()) % 5000)
FROM n;

CREATE INDEX idx_big_time ON my_big_log(answered_at);
CREATE INDEX idx_big_user ON my_big_log(user_name);
CREATE INDEX idx_big_q    ON my_big_log(question_id);

-- ---------------------------------------------------------------------
-- 1. 對欄位使用函數
-- ---------------------------------------------------------------------
-- ❌ 索引失效
EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE substr(answered_at, 1, 10) = '2025-03-01';

SELECT COUNT(*) FROM my_big_log WHERE substr(answered_at, 1, 10) = '2025-03-01';

-- ✅ 改寫成範圍條件
EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE answered_at >= '2025-03-01' AND answered_at < '2025-03-02';

SELECT COUNT(*) FROM my_big_log WHERE answered_at >= '2025-03-01' AND answered_at < '2025-03-02';

-- ---------------------------------------------------------------------
-- 2. 對欄位做運算
-- ---------------------------------------------------------------------
-- ❌
EXPLAIN QUERY PLAN
SELECT * FROM my_big_log WHERE question_id + 1 = 6;

-- ✅
EXPLAIN QUERY PLAN
SELECT * FROM my_big_log WHERE question_id = 6 - 1;

-- ---------------------------------------------------------------------
-- 3. LIKE 開頭是萬用字元
-- ---------------------------------------------------------------------
-- ❌ 開頭是 %，一定是全表掃描
EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE user_name LIKE '%1234';

-- SQLite 中，開頭確定的前綴查詢，可以改寫成範圍條件來使用索引
EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE user_name >= 'user12' AND user_name < 'user13';

-- ---------------------------------------------------------------------
-- 4. OR 連接不同欄位 → UNION
-- ---------------------------------------------------------------------
EXPLAIN QUERY PLAN
SELECT log_id FROM my_big_log WHERE user_name = 'user1' OR question_id = 5;
-- SQLite 很聰明，可能會用 MULTI-INDEX OR 同時使用兩個索引；其他資料庫不一定

EXPLAIN QUERY PLAN
SELECT log_id FROM my_big_log WHERE user_name = 'user1'
UNION
SELECT log_id FROM my_big_log WHERE question_id = 5;

-- ---------------------------------------------------------------------
-- 5. 深分頁：OFFSET vs 鍵集分頁
-- ---------------------------------------------------------------------
-- ❌ 要先讀過 15 萬筆
SELECT * FROM my_big_log ORDER BY log_id LIMIT 20 OFFSET 150000;

-- ✅ 直接從 log_id > 150000 開始
SELECT * FROM my_big_log WHERE log_id > 150000 ORDER BY log_id LIMIT 20;

-- ---------------------------------------------------------------------
-- 6. 相關子查詢 → 視窗函數
-- ---------------------------------------------------------------------
-- 每個使用者最近一次作答（只取部分使用者，避免跑太久）
-- ❌ 相關子查詢
SELECT COUNT(*) FROM my_big_log b
WHERE b.user_name LIKE 'user1%'
  AND b.answered_at = (SELECT MAX(answered_at) FROM my_big_log WHERE user_name = b.user_name);

-- ✅ 視窗函數
SELECT COUNT(*) FROM (
    SELECT user_name,
           ROW_NUMBER() OVER (PARTITION BY user_name ORDER BY answered_at DESC) AS rn
    FROM my_big_log
    WHERE user_name LIKE 'user1%'
) WHERE rn = 1;


-- =====================================================================
-- 練習題：改寫下列查詢，讓它能使用索引
-- =====================================================================

-- 練習 1：SELECT COUNT(*) FROM my_big_log WHERE strftime('%Y-%m', answered_at) = '2025-02';


-- 練習 2：SELECT COUNT(*) FROM my_big_log WHERE question_id * 2 = 20;


-- 練習 3：SELECT * FROM my_big_log WHERE question_id = 3 OR question_id = 7 OR question_id = 9;


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE answered_at >= '2025-02-01' AND answered_at < '2025-03-01';

-- 練習 2
EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE question_id = 10;

-- 練習 3
EXPLAIN QUERY PLAN
SELECT * FROM my_big_log WHERE question_id IN (3, 7, 9);

*/

DROP TABLE IF EXISTS my_big_log;
