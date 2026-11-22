-- =====================================================================
-- 3-2 INNER JOIN
-- =====================================================================

-- 範例 1：題目加上年度和科目
SELECT q.question_id, q.content, e.year, e.subject
FROM questions AS q
JOIN exams AS e ON q.exam_id = e.exam_id;

-- 範例 2：加上 WHERE，只看 113 年的題目
SELECT q.question_id, q.content, e.subject
FROM questions q
JOIN exams e ON q.exam_id = e.exam_id
WHERE e.year = 113;

-- 範例 3：題目與它的四個選項
SELECT q.question_id, q.content, o.label, o.content AS option_content
FROM questions q
JOIN options o ON q.question_id = o.question_id
WHERE q.question_id = 1;

-- 範例 4：題目與「正確答案的選項內容」
-- ON 條件可以有多個
SELECT q.question_id, q.content, q.answer, o.content AS 正確答案內容
FROM questions q
JOIN options o ON q.question_id = o.question_id AND q.answer = o.label;

-- 範例 5：三張表：題目 + 章節名稱
SELECT q.question_id, q.content, t.name AS 章節
FROM questions q
JOIN question_topics qt ON q.question_id = qt.question_id
JOIN topics t           ON qt.topic_id   = t.topic_id
ORDER BY q.question_id;

-- 範例 6：每個章節各有幾題
SELECT t.name AS 章節, COUNT(*) AS 題數
FROM question_topics qt
JOIN topics t ON qt.topic_id = t.topic_id
GROUP BY t.name
ORDER BY 題數 DESC;

-- 範例 7：作答紀錄加上題目內容（沒被作答過的題目不會出現）
SELECT p.answered_at, p.question_id, q.content, p.chosen, q.answer, p.is_correct
FROM practice_log p
JOIN questions q ON p.question_id = q.question_id;

-- 範例 8：舊式寫法，結果與範例 1 相同
SELECT q.question_id, q.content, e.year, e.subject
FROM questions q, exams e
WHERE q.exam_id = e.exam_id;

-- 範例 9：NATURAL JOIN（了解即可，不建議使用）
SELECT question_id, year, subject FROM questions NATURAL JOIN exams;

-- 範例 10：❌ 欄位名稱不明確：exam_id 兩張表都有（預期錯誤）
-- 預期錯誤
SELECT exam_id, content FROM questions q JOIN exams e ON q.exam_id = e.exam_id;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：列出所有網路概論的題目，顯示年度、題號、題目內容，依年度和題號排序


-- 練習 2：列出所有作答紀錄，顯示作答時間、題目內容、你選的選項內容
--        提示：options 要同時用 question_id 和 label 去對應 chosen


-- 練習 3：列出屬於「資料庫」章節的所有題目（顯示年度、科目、題目內容）


-- 練習 4：每份考試（顯示年度和科目）的作答次數和答對次數
--        沒被作答過的考試不用顯示


-- 練習 5：每個章節的作答答對率，依答對率由低到高排序（找出弱點章節）


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT e.year, q.question_no, q.content
FROM questions q
JOIN exams e ON q.exam_id = e.exam_id
WHERE e.subject = '網路概論'
ORDER BY e.year, q.question_no;

-- 練習 2
SELECT p.answered_at, q.content, o.content AS 我的選擇
FROM practice_log p
JOIN questions q ON p.question_id = q.question_id
JOIN options o   ON p.question_id = o.question_id AND p.chosen = o.label;

-- 練習 3
SELECT e.year, e.subject, q.content
FROM questions q
JOIN exams e            ON q.exam_id = e.exam_id
JOIN question_topics qt ON q.question_id = qt.question_id
JOIN topics t           ON qt.topic_id = t.topic_id
WHERE t.name = '資料庫';

-- 練習 4
SELECT e.year, e.subject, COUNT(*) AS 作答次數, SUM(p.is_correct) AS 答對次數
FROM practice_log p
JOIN questions q ON p.question_id = q.question_id
JOIN exams e     ON q.exam_id = e.exam_id
GROUP BY e.exam_id, e.year, e.subject;

-- 練習 5
SELECT t.name, COUNT(*) AS 作答次數,
       SUM(p.is_correct) * 1.0 / COUNT(*) AS 答對率
FROM practice_log p
JOIN question_topics qt ON p.question_id = qt.question_id
JOIN topics t           ON qt.topic_id = t.topic_id
GROUP BY t.name
ORDER BY 答對率;

*/
