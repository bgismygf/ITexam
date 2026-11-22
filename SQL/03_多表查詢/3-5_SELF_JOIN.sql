-- =====================================================================
-- 3-5 Self Join 自我合併
-- =====================================================================

-- 範例 1：同一科目、不同年度的考試配對
SELECT a.exam_id, a.year AS 年度1, b.exam_id, b.year AS 年度2, a.subject
FROM exams a
JOIN exams b ON a.subject = b.subject AND a.year < b.year;

-- 範例 2：同一份考試中，答案相同的題目配對
SELECT a.exam_id, a.question_no AS 題號1, b.question_no AS 題號2, a.answer
FROM questions a
JOIN questions b ON a.exam_id = b.exam_id
                AND a.answer = b.answer
                AND a.question_no < b.question_no
ORDER BY a.exam_id, a.question_no;

-- 範例 3：階層資料示範
-- 先用 WITH 臨時建立一張員工表（WITH 的用法在 4-5 課會教，這裡先照著執行）
WITH employees(emp_id, name, manager_id) AS (
    VALUES (1, '王總經理', NULL),
           (2, '李經理',   1),
           (3, '張經理',   1),
           (4, '陳工程師', 2),
           (5, '林工程師', 2),
           (6, '黃專員',   3)
)
SELECT e.name AS 員工, m.name AS 主管
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：找出「內容完全相同的選項」出現在不同題目的情況
--        （例如 '先進先出（FIFO）' 同時出現在第 3 題和第 9 題）
--        顯示兩個題目編號和選項內容


-- 練習 2：用範例 3 的員工表，列出每位主管和他有幾位直屬部屬
--        （沒有部屬的人不用列出）


-- 練習 3：找出被作答過兩次以上的題目，顯示「先前的作答」和「後來的作答」配對
--        （提示：同一 question_id，a.answered_at < b.answered_at）


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT a.question_id AS 題目1, b.question_id AS 題目2, a.content
FROM options a
JOIN options b ON a.content = b.content AND a.question_id < b.question_id;

-- 練習 2
WITH employees(emp_id, name, manager_id) AS (
    VALUES (1, '王總經理', NULL), (2, '李經理', 1), (3, '張經理', 1),
           (4, '陳工程師', 2), (5, '林工程師', 2), (6, '黃專員', 3)
)
SELECT m.name AS 主管, COUNT(*) AS 直屬部屬數
FROM employees e
JOIN employees m ON e.manager_id = m.emp_id
GROUP BY m.emp_id, m.name;

-- 練習 3
SELECT a.question_id,
       a.answered_at AS 先前作答, a.is_correct AS 先前結果,
       b.answered_at AS 後來作答, b.is_correct AS 後來結果
FROM practice_log a
JOIN practice_log b ON a.question_id = b.question_id
                   AND a.answered_at < b.answered_at;
-- 第 8 題：先答錯，後來答對

*/
