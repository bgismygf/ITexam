-- =====================================================================
-- 3-1 為什麼要拆成多張表
-- 本課只是觀察，還不用寫 JOIN
-- =====================================================================

-- 範例 1：第 1 題屬於哪一份考試？先查 questions
SELECT question_id, exam_id, content FROM questions WHERE question_id = 1;

-- 範例 2：再用 exam_id = 1 去查 exams
SELECT * FROM exams WHERE exam_id = 1;
-- 這樣「手動」查兩次很麻煩，下一課的 JOIN 可以一次完成

-- 範例 3：第 19 題的選項，存在 options 表
SELECT * FROM options WHERE question_id = 19;

-- 範例 4：第 19 題屬於哪些章節？
SELECT * FROM question_topics WHERE question_id = 19;
-- 結果是 topic_id = 1 和 7，再去 topics 查名稱
SELECT * FROM topics WHERE topic_id IN (1, 7);


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：第 26 題是哪一年、哪個科目的考試？（分兩次查詢）


-- 練習 2：第 26 題屬於哪些章節？寫出章節名稱（分兩次查詢）


-- 練習 3（思考題）：practice_log 只存 question_id，沒有存題目內容。
--        這樣設計有什麼好處？


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT exam_id FROM questions WHERE question_id = 26;   -- exam_id = 5
SELECT year, subject FROM exams WHERE exam_id = 5;      -- 113 年 網路概論

-- 練習 2
SELECT topic_id FROM question_topics WHERE question_id = 26;   -- 4, 7
SELECT name FROM topics WHERE topic_id IN (4, 7);              -- 網路、資訊安全

-- 練習 3
-- 1. 題目內容很長，每次作答都存一份會浪費空間
-- 2. 題目內容若要修正錯字，只要改 questions 一個地方，所有紀錄自動顯示新內容
-- 3. 避免「同一題在不同紀錄中內容不一樣」的不一致問題

*/
