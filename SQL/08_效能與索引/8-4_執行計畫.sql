-- =====================================================================
-- 8-4 讀懂執行計畫 EXPLAIN QUERY PLAN
-- =====================================================================

-- 準備：產生 20 萬筆資料（與 8-3 相同）
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

-- ---------------------------------------------------------------------
-- 範例 1：用主鍵查詢 → SEARCH ... USING INTEGER PRIMARY KEY
-- ---------------------------------------------------------------------
EXPLAIN QUERY PLAN
SELECT * FROM my_big_log WHERE log_id = 12345;

-- ---------------------------------------------------------------------
-- 範例 2：沒有索引 → SCAN（全表掃描）
-- ---------------------------------------------------------------------
EXPLAIN QUERY PLAN
SELECT * FROM my_big_log WHERE user_name = 'user1234';

-- 建立索引後 → SEARCH ... USING INDEX
CREATE INDEX idx_big_user ON my_big_log(user_name);

EXPLAIN QUERY PLAN
SELECT * FROM my_big_log WHERE user_name = 'user1234';

-- ---------------------------------------------------------------------
-- 範例 3：涵蓋索引 → USING COVERING INDEX
-- ---------------------------------------------------------------------
EXPLAIN QUERY PLAN
SELECT user_name FROM my_big_log WHERE user_name LIKE 'user12%';
-- 結果是 SCAN ... USING COVERING INDEX：只用到 user_name，索引裡就有，不用讀資料表，
-- 但 LIKE 無法用索引「搜尋」，所以是把整個索引掃一遍（SQLite 的 LIKE 不分大小寫，下一課說明）

EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE user_name = 'user1234';

-- ---------------------------------------------------------------------
-- 範例 4：額外排序 → USE TEMP B-TREE FOR ORDER BY
-- ---------------------------------------------------------------------
EXPLAIN QUERY PLAN
SELECT * FROM my_big_log WHERE user_name = 'user1234' ORDER BY answered_at;

-- 建立複合索引 (user_name, answered_at)，排序就可以利用索引
CREATE INDEX idx_big_user_time ON my_big_log(user_name, answered_at);

EXPLAIN QUERY PLAN
SELECT * FROM my_big_log WHERE user_name = 'user1234' ORDER BY answered_at;

-- ---------------------------------------------------------------------
-- 範例 5：最左前綴原則
-- ---------------------------------------------------------------------
CREATE INDEX idx_big_q_correct ON my_big_log(question_id, is_correct);

EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE question_id = 5 AND is_correct = 1;   -- ✅ 用到

EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE question_id = 5;                      -- ✅ 用到

EXPLAIN QUERY PLAN
SELECT COUNT(*) FROM my_big_log WHERE is_correct = 1;                       -- ❌ 不能用來搜尋（SCAN ... USING COVERING INDEX）

-- ---------------------------------------------------------------------
-- 範例 6：JOIN 的執行計畫
-- ---------------------------------------------------------------------
EXPLAIN QUERY PLAN
SELECT q.content, COUNT(*)
FROM my_big_log b
JOIN questions q ON b.question_id = q.question_id
GROUP BY q.content;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：看看下列查詢的執行計畫，判斷有沒有用到索引
--        SELECT * FROM my_big_log WHERE answered_at > '2025-06-01';
--        如果沒有，建立適當的索引後再看一次


-- 練習 2：看看原本題庫的這個查詢，執行計畫是什麼？
--        SELECT * FROM practice_log p JOIN questions q ON p.question_id = q.question_id;


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
EXPLAIN QUERY PLAN SELECT * FROM my_big_log WHERE answered_at > '2025-06-01';   -- SCAN
CREATE INDEX idx_big_time ON my_big_log(answered_at);
EXPLAIN QUERY PLAN SELECT * FROM my_big_log WHERE answered_at > '2025-06-01';
-- SEARCH ... USING INDEX idx_big_time (answered_at>?)
-- 注意：如果符合條件的資料佔了大部分，最佳化器可能還是選擇 SCAN（比較快）

-- 練習 2
EXPLAIN QUERY PLAN
SELECT * FROM practice_log p JOIN questions q ON p.question_id = q.question_id;
-- SCAN p（practice_log 全表掃描，因為要讀全部）
-- SEARCH q USING INTEGER PRIMARY KEY（用主鍵找題目）

*/

DROP TABLE IF EXISTS my_big_log;
