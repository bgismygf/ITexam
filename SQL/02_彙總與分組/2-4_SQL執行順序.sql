-- =====================================================================
-- 2-4 SQL 的執行順序
-- 執行順序：FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
-- =====================================================================

-- 範例 1：講義中的完整例子，可以把下面每個步驟拆開執行，觀察資料的變化
SELECT exam_id, COUNT(*) AS 題數
FROM questions
WHERE score = 2
GROUP BY exam_id
HAVING COUNT(*) >= 6
ORDER BY 題數 DESC
LIMIT 2;

-- 步驟 1：FROM
SELECT * FROM questions;

-- 步驟 2：FROM + WHERE
SELECT * FROM questions WHERE score = 2;

-- 步驟 3：+ GROUP BY
SELECT exam_id, COUNT(*) FROM questions WHERE score = 2 GROUP BY exam_id;

-- 步驟 4：+ HAVING
SELECT exam_id, COUNT(*) FROM questions WHERE score = 2
GROUP BY exam_id HAVING COUNT(*) >= 6;

-- 範例 2：ORDER BY 可以使用別名
SELECT exam_id, SUM(score) AS 總分
FROM questions
GROUP BY exam_id
ORDER BY 總分 DESC;

-- 範例 3：SQLite 允許 WHERE 使用別名，但這不是標準寫法
--        （在 SQL Server / Oracle 會出錯）
SELECT question_id, score * 2 AS 加倍
FROM questions
WHERE 加倍 > 4;

-- 範例 4：標準寫法：在 WHERE 重寫一次運算式
SELECT question_id, score * 2 AS 加倍
FROM questions
WHERE score * 2 > 4;


-- =====================================================================
-- 練習題（綜合第 1、2 單元）
-- =====================================================================

-- 練習 1：計算每個年度的總題數（用 exams.question_count），
--        只顯示總題數大於 6 的年度，依總題數由大到小排序


-- 練習 2：作答紀錄中，每題的答錯次數，只看答錯過的題目，
--        依答錯次數由多到少，再依 question_id 排序，只取前 3 名


-- 練習 3：找出「答案選項」裡，題目數量最多的那一個（排除 NULL）


-- 練習 4：下面的 SQL 有 3 個錯誤（以標準 SQL 來看），請找出來並修正
--        SELECT exam_id, content, COUNT(*) AS cnt
--        FROM questions
--        WHERE cnt > 5
--        GROUP BY exam_id;


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT year, SUM(question_count) AS 總題數
FROM exams
GROUP BY year
HAVING SUM(question_count) > 6
ORDER BY 總題數 DESC;
-- 113 年：11 題、111 年：7 題

-- 練習 2
SELECT question_id, COUNT(*) AS 答錯次數
FROM practice_log
WHERE is_correct = 0
GROUP BY question_id
ORDER BY 答錯次數 DESC, question_id
LIMIT 3;

-- 練習 3
SELECT answer, COUNT(*) AS 題數
FROM questions
WHERE answer IS NOT NULL
GROUP BY answer
ORDER BY 題數 DESC
LIMIT 1;
-- ⚠️ 注意：B 和 C 都是 10 題，同分！LIMIT 1 只會顯示其中一個，而且不保證是哪一個。
-- 這是 LIMIT 的陷阱。要把同分的都列出來，需要子查詢（4-1 課）或視窗函數 RANK()（4-6 課）

-- 練習 4
-- 錯誤 1：content 不在 GROUP BY 中，也不是彙總函數 → 刪掉
-- 錯誤 2：WHERE 不能使用 SELECT 的別名 cnt
-- 錯誤 3：WHERE 不能使用彙總函數，篩選組要用 HAVING
SELECT exam_id, COUNT(*) AS cnt
FROM questions
GROUP BY exam_id
HAVING COUNT(*) > 5;

*/
