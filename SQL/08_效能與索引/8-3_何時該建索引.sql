-- =====================================================================
-- 8-3 何時該建索引：用 20 萬筆資料比較速度
-- 執行後看 DB Browser 下方訊息區的執行時間（took ...ms）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 準備：產生 20 萬筆模擬作答紀錄（需要幾秒鐘）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS my_big_log;
CREATE TABLE my_big_log (
    log_id      INTEGER PRIMARY KEY,
    question_id INTEGER,
    answered_at TEXT,
    chosen      TEXT,
    is_correct  INTEGER,
    user_name   TEXT
);

INSERT INTO my_big_log (question_id, answered_at, chosen, is_correct, user_name)
WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 200000)
SELECT abs(random()) % 30 + 1,
       datetime('2025-01-01', '+' || (i * 2) || ' minutes'),
       char(65 + abs(random()) % 4),
       abs(random()) % 2,
       'user' || (abs(random()) % 5000)
FROM n;

SELECT COUNT(*) FROM my_big_log;

-- ---------------------------------------------------------------------
-- 比較 1：沒有索引 vs 有索引（等值查詢）
-- ---------------------------------------------------------------------

-- 沒有索引：記下執行時間
SELECT COUNT(*) FROM my_big_log WHERE user_name = 'user1234';

-- 建立索引
CREATE INDEX idx_big_user ON my_big_log(user_name);

-- 有索引：再執行一次，比較時間
SELECT COUNT(*) FROM my_big_log WHERE user_name = 'user1234';

-- ---------------------------------------------------------------------
-- 比較 2：範圍查詢
-- ---------------------------------------------------------------------
SELECT COUNT(*) FROM my_big_log
WHERE answered_at >= '2025-03-01' AND answered_at < '2025-03-02';

CREATE INDEX idx_big_time ON my_big_log(answered_at);

SELECT COUNT(*) FROM my_big_log
WHERE answered_at >= '2025-03-01' AND answered_at < '2025-03-02';

-- ---------------------------------------------------------------------
-- 比較 3：索引讓寫入變慢
-- ---------------------------------------------------------------------
-- 有 2 個索引時，更新 2 萬筆
UPDATE my_big_log SET answered_at = answered_at, user_name = user_name WHERE log_id <= 20000;

-- 刪除索引後，再更新一次，比較時間
DROP INDEX idx_big_user;
DROP INDEX idx_big_time;
UPDATE my_big_log SET answered_at = answered_at, user_name = user_name WHERE log_id <= 20000;

-- ---------------------------------------------------------------------
-- 選擇性：計算各欄位的選擇性
-- ---------------------------------------------------------------------
SELECT
    COUNT(DISTINCT log_id)      * 1.0 / COUNT(*) AS log_id_選擇性,
    COUNT(DISTINCT user_name)   * 1.0 / COUNT(*) AS user_name_選擇性,
    COUNT(DISTINCT question_id) * 1.0 / COUNT(*) AS question_id_選擇性,
    COUNT(DISTINCT is_correct)  * 1.0 / COUNT(*) AS is_correct_選擇性
FROM my_big_log;
-- is_correct 只有 0、1 兩種值，選擇性極低，建索引幫助不大

-- ---------------------------------------------------------------------
-- 複合索引與最左前綴（下一課會用 EXPLAIN 確認有沒有用到索引）
-- ---------------------------------------------------------------------
CREATE INDEX idx_big_q_user ON my_big_log(question_id, user_name);

SELECT COUNT(*) FROM my_big_log WHERE question_id = 5 AND user_name = 'user100';  -- ✅ 用得到
SELECT COUNT(*) FROM my_big_log WHERE question_id = 5;                           -- ✅ 用得到
SELECT COUNT(*) FROM my_big_log WHERE user_name = 'user100';                     -- ❌ 用不到


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：查詢「某位使用者答錯的紀錄，依時間排序」：
--        SELECT * FROM my_big_log WHERE user_name = 'user77' AND is_correct = 0 ORDER BY answered_at;
--        你會建立什麼樣的索引？建立後比較速度


-- 練習 2：原本的題庫中，哪些外來鍵欄位應該建索引？寫出 CREATE INDEX


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT * FROM my_big_log WHERE user_name = 'user77' AND is_correct = 0 ORDER BY answered_at;
CREATE INDEX idx_big_user_correct_time ON my_big_log(user_name, is_correct, answered_at);
SELECT * FROM my_big_log WHERE user_name = 'user77' AND is_correct = 0 ORDER BY answered_at;
-- 等值條件（user_name、is_correct）放前面，排序欄位（answered_at）放最後，
-- 這樣索引可以同時處理篩選和排序

-- 練習 2
CREATE INDEX IF NOT EXISTS idx_questions_exam   ON questions(exam_id);
CREATE INDEX IF NOT EXISTS idx_log_question     ON practice_log(question_id);
CREATE INDEX IF NOT EXISTS idx_qt_topic         ON question_topics(topic_id);
-- 說明：
-- questions(exam_id)：已經有 UNIQUE(exam_id, question_no)，依最左前綴原則，其實已經涵蓋，可以不建
-- options(question_id)：主鍵是 (question_id, label)，已經涵蓋
-- question_topics(question_id)：主鍵是 (question_id, topic_id)，已經涵蓋；但 topic_id 沒有，要建
-- 題庫資料量很小，實際上不建也沒差；這裡是練習判斷

*/

-- 練習結束後可以刪除大表（約 10MB）
DROP TABLE IF EXISTS my_big_log;
