-- =====================================================================
-- 3-3 LEFT / RIGHT / FULL OUTER JOIN
-- =====================================================================

-- 範例 1：INNER JOIN，只會出現被作答過的題目
SELECT q.question_id, COUNT(*) AS 作答次數
FROM questions q
JOIN practice_log p ON q.question_id = p.question_id
GROUP BY q.question_id;

-- 範例 2：LEFT JOIN，保留所有題目，沒作答的右表欄位是 NULL
SELECT q.question_id, p.log_id, p.is_correct
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id;

-- 範例 3：每題作答次數（包含 0 次）—— 要用 COUNT(p.log_id)
SELECT q.question_id,
       COUNT(p.log_id) AS 正確寫法,
       COUNT(*)        AS 錯誤寫法
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id
GROUP BY q.question_id;

-- 範例 4：LEFT JOIN + IS NULL，找出從來沒被作答過的題目
SELECT q.question_id, q.content
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id
WHERE p.log_id IS NULL;

-- 範例 5：條件放 ON（每題都保留）
SELECT q.question_id, p.log_id
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id AND p.is_correct = 1;

-- 範例 6：條件放 WHERE（變得跟 INNER JOIN 一樣）
SELECT q.question_id, p.log_id
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id
WHERE p.is_correct = 1;

-- 範例 7：RIGHT JOIN（需要 SQLite 3.39 以上），等於把兩張表左右對調的 LEFT JOIN
SELECT q.question_id, p.log_id
FROM practice_log p
RIGHT JOIN questions q ON q.question_id = p.question_id;

-- 範例 8：FULL OUTER JOIN（需要 SQLite 3.39 以上）
-- 比較「有被作答過的題目」和「屬於資料庫章節的題目」兩份清單
SELECT a.question_id AS 作答過, b.question_id AS 資料庫章節
FROM (SELECT DISTINCT question_id FROM practice_log) a
FULL OUTER JOIN (SELECT question_id FROM question_topics WHERE topic_id = 1) b
     ON a.question_id = b.question_id;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：列出每個章節的名稱和題數，包含沒有題目的章節（目前每章都有題目，
--        但寫法要能處理沒有題目的情況）


-- 練習 2：找出還沒有被歸類到任何章節的題目
--        （目前應該沒有，結果是空的，但寫法要正確）


-- 練習 3：列出每份考試的年度、科目和作答次數，沒被作答過的考試顯示 0


-- 練習 4：列出所有題目，以及「答錯」的次數（沒答錯過的顯示 0）
--        提示：is_correct = 0 的條件要放 ON 還是 WHERE？


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT t.name, COUNT(qt.question_id) AS 題數
FROM topics t
LEFT JOIN question_topics qt ON t.topic_id = qt.topic_id
GROUP BY t.topic_id, t.name;

-- 練習 2
SELECT q.question_id, q.content
FROM questions q
LEFT JOIN question_topics qt ON q.question_id = qt.question_id
WHERE qt.question_id IS NULL;

-- 練習 3
SELECT e.year, e.subject, COUNT(p.log_id) AS 作答次數
FROM exams e
LEFT JOIN questions q    ON e.exam_id = q.exam_id
LEFT JOIN practice_log p ON q.question_id = p.question_id
GROUP BY e.exam_id, e.year, e.subject;
-- 注意：第二個 JOIN 也要用 LEFT，否則沒作答的題目會在這一步被丟掉

-- 練習 4：條件放 ON
SELECT q.question_id, COUNT(p.log_id) AS 答錯次數
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id AND p.is_correct = 0
GROUP BY q.question_id;

*/
