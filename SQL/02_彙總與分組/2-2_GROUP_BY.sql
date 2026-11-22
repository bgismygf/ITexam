-- =====================================================================
-- 2-2 GROUP BY 分組
-- =====================================================================

-- 範例 1：每份考試有幾題
SELECT exam_id, COUNT(*) AS 題數
FROM questions
GROUP BY exam_id;

-- 範例 2：每份考試的總配分、平均配分
SELECT exam_id, SUM(score) AS 總配分, AVG(score) AS 平均配分
FROM questions
GROUP BY exam_id;

-- 範例 3：每個科目各有幾份考試
SELECT subject, COUNT(*) AS 考試份數
FROM exams
GROUP BY subject;

-- 範例 4：多欄位分組
SELECT year, subject, SUM(question_count) AS 題數
FROM exams
GROUP BY year, subject;

-- 範例 5：各答案選項出現幾次（NULL 會自成一組）
SELECT answer, COUNT(*) AS 次數
FROM questions
GROUP BY answer;

-- 範例 6：WHERE + GROUP BY + ORDER BY
SELECT exam_id, COUNT(*) AS 題數
FROM questions
WHERE score >= 2
GROUP BY exam_id
ORDER BY 題數 DESC;

-- 範例 7：每題的作答次數和答對次數
SELECT question_id, COUNT(*) AS 作答次數, SUM(is_correct) AS 答對次數
FROM practice_log
GROUP BY question_id;

-- 範例 8：❌ 錯誤示範（SQLite 不報錯，但 content 是隨便挑的一題）
SELECT exam_id, content, COUNT(*)
FROM questions
GROUP BY exam_id;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：每個年度各有幾份考試


-- 練習 2：每個章節（topic_id）各有幾題（使用 question_topics）


-- 練習 3：每天（日期部分）的作答次數
--        提示：substr(answered_at, 1, 10) 可以取出前 10 個字元，也就是日期


-- 練習 4：每份考試中，各種配分各有幾題（依 exam_id、score 分組）


-- 練習 5：每份考試中，答案分別是 A、B、C、D 的題數，
--        依 exam_id、answer 排序


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT year, COUNT(*) FROM exams GROUP BY year;

-- 練習 2
SELECT topic_id, COUNT(*) AS 題數
FROM question_topics
GROUP BY topic_id;
-- topic_id 是數字，看不出章節名稱；第 3 單元學 JOIN 之後就能顯示名稱

-- 練習 3
SELECT substr(answered_at, 1, 10) AS 日期, COUNT(*) AS 作答次數
FROM practice_log
GROUP BY substr(answered_at, 1, 10);

-- 練習 4
SELECT exam_id, score, COUNT(*)
FROM questions
GROUP BY exam_id, score;

-- 練習 5
SELECT exam_id, answer, COUNT(*)
FROM questions
GROUP BY exam_id, answer
ORDER BY exam_id, answer;

*/
