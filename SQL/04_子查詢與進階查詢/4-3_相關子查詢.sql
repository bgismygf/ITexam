-- =====================================================================
-- 4-3 相關子查詢
-- =====================================================================

-- 範例 1：配分高於「該份考試」平均的題目
SELECT q.exam_id, q.question_id, q.score
FROM questions q
WHERE q.score > (SELECT AVG(score) FROM questions WHERE exam_id = q.exam_id);

-- 範例 2：每份考試中配分最高的題目（同分會全部列出）
SELECT q.exam_id, q.question_id, q.score
FROM questions q
WHERE q.score = (SELECT MAX(score) FROM questions WHERE exam_id = q.exam_id)
ORDER BY q.exam_id, q.question_id;

-- 範例 3：每題最近一次的作答紀錄
SELECT * FROM practice_log p
WHERE p.answered_at = (SELECT MAX(answered_at) FROM practice_log
                       WHERE question_id = p.question_id);

-- 範例 4：放在 SELECT 中的相關子查詢：每份考試的題數
SELECT e.exam_id, e.year, e.subject,
       (SELECT COUNT(*) FROM questions q WHERE q.exam_id = e.exam_id) AS 實際題數
FROM exams e;

-- 範例 5：相關子查詢改寫成 JOIN + GROUP BY（結果與範例 4 相同）
SELECT e.exam_id, e.year, e.subject, COUNT(q.question_id) AS 實際題數
FROM exams e
LEFT JOIN questions q ON q.exam_id = e.exam_id
GROUP BY e.exam_id, e.year, e.subject;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：找出每份考試的最後一題（題號最大的那題），顯示 exam_id、題號、內容


-- 練習 2：列出每個章節的名稱，以及該章節的作答次數（用 SELECT 中的相關子查詢）


-- 練習 3（本單元練習）：找出「最近一次作答是答錯」的題目
--        也就是：答錯過，而且後來還沒有答對的題目
--        提示：沿用範例 3，再加上 is_correct = 0


-- 練習 4：檢查資料：exams.question_count 和實際題數不一致的考試
--        （目前應該都一致，結果為空）


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT q.exam_id, q.question_no, q.content
FROM questions q
WHERE q.question_no = (SELECT MAX(question_no) FROM questions WHERE exam_id = q.exam_id);

-- 練習 2
SELECT t.name,
       (SELECT COUNT(*)
        FROM practice_log p
        JOIN question_topics qt ON p.question_id = qt.question_id
        WHERE qt.topic_id = t.topic_id) AS 作答次數
FROM topics t;

-- 練習 3
SELECT p.question_id, p.answered_at, p.chosen
FROM practice_log p
WHERE p.is_correct = 0
  AND p.answered_at = (SELECT MAX(answered_at) FROM practice_log
                       WHERE question_id = p.question_id);
-- 結果：第 2、13、16、22 題（第 8 題後來答對了，所以不在裡面）

-- 練習 4
SELECT e.* FROM exams e
WHERE e.question_count <> (SELECT COUNT(*) FROM questions q WHERE q.exam_id = e.exam_id);

*/
