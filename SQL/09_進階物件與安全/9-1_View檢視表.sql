-- =====================================================================
-- 9-1 View 檢視表
-- 本課建立的 View 很實用，建議保留（執行後按 Write Changes 存檔）
-- =====================================================================

-- 範例 1：題目完整資訊（包含年度、科目、正確答案內容）
DROP VIEW IF EXISTS v_question_detail;
CREATE VIEW v_question_detail AS
SELECT q.question_id, e.year, e.subject, q.question_no, q.content, q.score,
       q.answer, o.content AS answer_text
FROM questions q
JOIN exams e        ON q.exam_id = e.exam_id
LEFT JOIN options o ON o.question_id = q.question_id AND o.label = q.answer;

SELECT * FROM v_question_detail;

-- 像資料表一樣使用：加 WHERE、ORDER BY
SELECT question_id, content, answer_text
FROM v_question_detail
WHERE year = 113 AND subject = '網路概論';

-- 範例 2：每題的作答統計（包含沒作答過的題目）
DROP VIEW IF EXISTS v_question_stats;
CREATE VIEW v_question_stats AS
SELECT q.question_id,
       COUNT(p.log_id)                         AS attempts,
       COALESCE(SUM(p.is_correct), 0)          AS correct,
       ROUND(AVG(p.is_correct * 1.0), 2)       AS correct_rate,
       MAX(p.answered_at)                      AS last_answered
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id
GROUP BY q.question_id;

SELECT * FROM v_question_stats;

-- 範例 3：View 可以和資料表、其他 View 一起 JOIN
SELECT d.year, d.subject, d.content, s.attempts, s.correct_rate
FROM v_question_detail d
JOIN v_question_stats s ON d.question_id = s.question_id
WHERE s.attempts > 0
ORDER BY s.correct_rate;

-- 範例 4：每章節的答對率（弱點分析用）
DROP VIEW IF EXISTS v_topic_stats;
CREATE VIEW v_topic_stats AS
SELECT t.topic_id, t.name,
       COUNT(DISTINCT qt.question_id)    AS question_count,
       COUNT(p.log_id)                   AS attempts,
       ROUND(AVG(p.is_correct * 1.0), 2) AS correct_rate
FROM topics t
LEFT JOIN question_topics qt ON t.topic_id = qt.topic_id
LEFT JOIN practice_log p     ON qt.question_id = p.question_id
GROUP BY t.topic_id, t.name;

SELECT * FROM v_topic_stats ORDER BY correct_rate;

-- 範例 5：查看資料庫中有哪些 View
SELECT name, sql FROM sqlite_master WHERE type = 'view';

-- 範例 6：SQLite 的 View 是唯讀的（預期錯誤）
-- 預期錯誤
UPDATE v_question_detail SET answer = 'A' WHERE question_id = 1;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：建立 View「v_wrong_questions」：最近一次作答是答錯的題目
--        （顯示題目編號、年度、科目、題目內容、正確答案、你上次選的答案）
--        提示：沿用 4-6 課練習 3 的寫法


-- 練習 2：建立 View「v_exam_summary」：每份考試的年度、科目、題數、總配分、作答次數


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
DROP VIEW IF EXISTS v_wrong_questions;
CREATE VIEW v_wrong_questions AS
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY question_id ORDER BY answered_at DESC) AS rn
    FROM practice_log
)
SELECT d.question_id, d.year, d.subject, d.content, d.answer, r.chosen AS last_chosen
FROM ranked r
JOIN v_question_detail d ON r.question_id = d.question_id
WHERE r.rn = 1 AND r.is_correct = 0;

SELECT * FROM v_wrong_questions;

-- 練習 2
DROP VIEW IF EXISTS v_exam_summary;
CREATE VIEW v_exam_summary AS
SELECT e.exam_id, e.year, e.subject,
       COUNT(DISTINCT q.question_id) AS question_count,
       (SELECT SUM(score) FROM questions WHERE exam_id = e.exam_id) AS total_score,
       COUNT(p.log_id) AS attempts
FROM exams e
LEFT JOIN questions q    ON e.exam_id = q.exam_id
LEFT JOIN practice_log p ON q.question_id = p.question_id
GROUP BY e.exam_id, e.year, e.subject;

SELECT * FROM v_exam_summary;

*/
