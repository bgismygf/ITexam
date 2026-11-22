-- =====================================================================
-- 4-6 視窗函數
-- =====================================================================

-- 範例 1：每一列都保留，旁邊加上該考試的平均和總分
SELECT question_id, exam_id, score,
       AVG(score) OVER (PARTITION BY exam_id) AS 該考試平均,
       SUM(score) OVER (PARTITION BY exam_id) AS 該考試總分,
       COUNT(*)   OVER ()                     AS 全部題數
FROM questions;

-- 範例 2：三種排名函數的差別（依考試題數排名）
SELECT exam_id, question_count,
       ROW_NUMBER() OVER (ORDER BY question_count DESC) AS row_number,
       RANK()       OVER (ORDER BY question_count DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY question_count DESC) AS dense_rank
FROM exams;

-- 範例 3：組內排名：每份考試內，依配分由高到低
SELECT exam_id, question_id, score,
       RANK() OVER (PARTITION BY exam_id ORDER BY score DESC) AS 組內排名
FROM questions;

-- 範例 4：⭐ 每題最近一次的作答（每組取第 1 名）
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY question_id ORDER BY answered_at DESC) AS rn
    FROM practice_log
)
SELECT log_id, question_id, answered_at, is_correct
FROM ranked
WHERE rn = 1;

-- 範例 5：累計答對次數
SELECT answered_at, question_id, is_correct,
       SUM(is_correct) OVER (ORDER BY answered_at) AS 累計答對,
       COUNT(*)        OVER (ORDER BY answered_at) AS 累計作答
FROM practice_log;

-- 範例 6：LAG：同一題的上一次作答結果
SELECT question_id, answered_at, is_correct,
       LAG(is_correct) OVER (PARTITION BY question_id ORDER BY answered_at) AS 上次結果
FROM practice_log
ORDER BY question_id, answered_at;

-- 範例 7：LAG：每次作答距離上一次作答隔了多久（分鐘）
SELECT answered_at,
       LAG(answered_at) OVER (ORDER BY answered_at) AS 上一次,
       ROUND((julianday(answered_at)
              - julianday(LAG(answered_at) OVER (ORDER BY answered_at))) * 24 * 60) AS 間隔分鐘
FROM practice_log;

-- 範例 8：❌ 視窗函數不能直接放在 WHERE（預期錯誤）
-- 預期錯誤
SELECT * FROM practice_log
WHERE ROW_NUMBER() OVER (ORDER BY answered_at) = 1;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：列出每一題，以及「它的配分佔該考試總分的百分比」


-- 練習 2：每個章節中，作答次數最多的題目（用 RANK，同次數都列出）


-- 練習 3（本單元練習，用視窗函數重做 4-3 練習 3）：
--        找出「最近一次作答是答錯」的題目


-- 練習 4：每天的作答次數，以及「到當天為止的累計作答次數」


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT question_id, exam_id, score,
       ROUND(score * 100.0 / SUM(score) OVER (PARTITION BY exam_id), 1) AS 百分比
FROM questions;

-- 練習 2
WITH cnt AS (
    SELECT qt.topic_id, p.question_id, COUNT(*) AS 次數
    FROM practice_log p
    JOIN question_topics qt ON p.question_id = qt.question_id
    GROUP BY qt.topic_id, p.question_id
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY topic_id ORDER BY 次數 DESC) AS rk
    FROM cnt
)
SELECT t.name, r.question_id, r.次數
FROM ranked r JOIN topics t ON r.topic_id = t.topic_id
WHERE r.rk = 1
ORDER BY t.topic_id;

-- 練習 3
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY question_id ORDER BY answered_at DESC) AS rn
    FROM practice_log
)
SELECT question_id, answered_at
FROM ranked
WHERE rn = 1 AND is_correct = 0;   -- 第 2、13、16、22 題

-- 練習 4
SELECT 日期, 次數, SUM(次數) OVER (ORDER BY 日期) AS 累計
FROM (
    SELECT substr(answered_at, 1, 10) AS 日期, COUNT(*) AS 次數
    FROM practice_log
    GROUP BY substr(answered_at, 1, 10)
);

*/
