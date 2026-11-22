-- =====================================================================
-- 4-5 CTE（WITH 子句）
-- 注意：WITH 和後面的 SELECT 是「同一句」，要一起選取後執行（反白整段再按 Ctrl+Enter）
-- =====================================================================

-- 範例 1：基本 CTE
WITH exam_counts AS (
    SELECT exam_id, COUNT(*) AS 題數
    FROM questions
    GROUP BY exam_id
)
SELECT AVG(題數) FROM exam_counts;

-- 範例 2：CTE 重複使用：題數最多的考試
WITH exam_counts AS (
    SELECT exam_id, COUNT(*) AS cnt FROM questions GROUP BY exam_id
)
SELECT * FROM exam_counts
WHERE cnt = (SELECT MAX(cnt) FROM exam_counts);

-- 範例 3：多個 CTE，一步一步算出「每個章節的答對率」
WITH
log_with_topic AS (            -- 步驟 1：作答紀錄加上章節
    SELECT p.log_id, p.is_correct, qt.topic_id
    FROM practice_log p
    JOIN question_topics qt ON p.question_id = qt.question_id
),
topic_stats AS (               -- 步驟 2：每章節統計
    SELECT topic_id, COUNT(*) AS 作答, SUM(is_correct) AS 答對
    FROM log_with_topic
    GROUP BY topic_id
)
SELECT t.name, s.作答, s.答對, ROUND(s.答對 * 1.0 / s.作答, 2) AS 答對率
FROM topic_stats s
JOIN topics t ON s.topic_id = t.topic_id
ORDER BY 答對率;

-- 範例 4：遞迴 CTE：產生 1 到 10
WITH RECURSIVE nums(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 10
)
SELECT n FROM nums;

-- 範例 5：遞迴 CTE：產生 2026-11-01 到 2026-11-07 每一天，並統計每天作答次數
--        （沒有作答的日子也會顯示 0）
WITH RECURSIVE days(d) AS (
    SELECT '2026-11-01'
    UNION ALL
    SELECT date(d, '+1 day') FROM days WHERE d < '2026-11-07'
)
SELECT days.d AS 日期, COUNT(p.log_id) AS 作答次數
FROM days
LEFT JOIN practice_log p ON substr(p.answered_at, 1, 10) = days.d
GROUP BY days.d;

-- 範例 6：遞迴 CTE：組織架構，列出「王總經理」底下所有層級的部屬
WITH RECURSIVE
employees(emp_id, name, manager_id) AS (
    VALUES (1, '王總經理', NULL), (2, '李經理', 1), (3, '張經理', 1),
           (4, '陳工程師', 2), (5, '林工程師', 2), (6, '黃專員', 3), (7, '吳實習生', 4)
),
org(emp_id, name, level) AS (
    SELECT emp_id, name, 0 FROM employees WHERE manager_id IS NULL   -- 起點：總經理
    UNION ALL
    SELECT e.emp_id, e.name, org.level + 1
    FROM employees e
    JOIN org ON e.manager_id = org.emp_id                             -- 找下一層
)
SELECT level AS 層級, name FROM org ORDER BY level;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：用 CTE 改寫 4-1 練習 5：作答次數高於平均作答次數的題目


-- 練習 2：用 CTE 算出每份考試的「作答次數」和「答對率」，只顯示有作答過的考試


-- 練習 3：用遞迴 CTE 產生九九乘法表中「9 的倍數」那一列：9, 18, 27, ..., 81


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
WITH cnt AS (
    SELECT question_id, COUNT(*) AS 次數 FROM practice_log GROUP BY question_id
)
SELECT * FROM cnt WHERE 次數 > (SELECT AVG(次數) FROM cnt);

-- 練習 2
WITH log_exam AS (
    SELECT q.exam_id, p.is_correct
    FROM practice_log p
    JOIN questions q ON p.question_id = q.question_id
)
SELECT exam_id, COUNT(*) AS 作答次數, ROUND(AVG(is_correct * 1.0), 2) AS 答對率
FROM log_exam
GROUP BY exam_id;

-- 練習 3
WITH RECURSIVE nums(n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM nums WHERE n < 9
)
SELECT n * 9 FROM nums;

*/
