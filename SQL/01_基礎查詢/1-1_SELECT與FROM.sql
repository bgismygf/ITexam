-- =====================================================================
-- 1-1 SELECT 與 FROM
-- 使用方式：在 DB Browser for SQLite 打開 data/exam.db，逐句用 Shift+F5 執行
-- =====================================================================

-- 範例 1：查出 exams 的全部欄位
SELECT * FROM exams;

-- 範例 2：只看年度和科目
SELECT year, subject FROM exams;

-- 範例 3：欄位順序可以自己決定
SELECT subject, year FROM exams;

-- 範例 4：同一個欄位可以出現兩次（實務上少用，只是示範）
SELECT year, subject, year FROM exams;

-- 範例 5：欄位可以做計算
-- 如果把每題配分加倍，會是多少？
SELECT question_id, score, score * 2 FROM questions;

-- 範例 6：文字可以用 || 串接（SQLite、PostgreSQL、Oracle 的寫法；
--         MySQL 用 CONCAT()，SQL Server 用 + 或 CONCAT()）
SELECT year || '年 ' || subject FROM exams;

-- 範例 7：一個欄位一行的寫法，比較好讀
SELECT
    question_id,
    question_no,
    content
FROM questions;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：查出 topics 資料表的全部資料


-- 練習 2：查出所有題目的「題目編號（question_id）」和「題目內容（content）」


-- 練習 3：查出所有選項的 question_id、label、content


-- 練習 4：查出每份考試的 exam_id、subject，以及「題數乘以 2」


-- 練習 5：把每份考試顯示成「110年 資訊 計算機原理」這樣的格式


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT * FROM topics;

-- 練習 2
SELECT question_id, content FROM questions;

-- 練習 3
SELECT question_id, label, content FROM options;

-- 練習 4
SELECT exam_id, subject, question_count * 2 FROM exams;

-- 練習 5
SELECT year || '年 ' || category || ' ' || subject FROM exams;

*/
