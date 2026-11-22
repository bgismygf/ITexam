-- =====================================================================
-- 2-3 HAVING 與 WHERE 的差別
-- =====================================================================

-- 範例 1：題數超過 5 題的考試
SELECT exam_id, COUNT(*) AS 題數
FROM questions
GROUP BY exam_id
HAVING COUNT(*) > 5;

-- 範例 2：❌ WHERE 不能用彙總函數（會出現錯誤訊息，這是預期的）
-- 預期錯誤
SELECT exam_id, COUNT(*) FROM questions
WHERE COUNT(*) > 5
GROUP BY exam_id;

-- 範例 3：WHERE 和 HAVING 一起用
SELECT exam_id, COUNT(*) AS 題數
FROM questions
WHERE score = 2
GROUP BY exam_id
HAVING COUNT(*) >= 6;

-- 範例 4：找出被作答超過一次的題目
SELECT question_id, COUNT(*) AS 作答次數
FROM practice_log
GROUP BY question_id
HAVING COUNT(*) > 1;

-- 範例 5：屬於 2 個以上章節的題目
SELECT question_id, COUNT(*) AS 章節數
FROM question_topics
GROUP BY question_id
HAVING COUNT(*) >= 2;

-- 範例 6：總配分不是 12 分的考試
SELECT exam_id, SUM(score) AS 總配分
FROM questions
GROUP BY exam_id
HAVING SUM(score) <> 12;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：出題數 4 題以上的章節（topic_id）


-- 練習 2：有任何一題配分大於 2 的考試（用 MAX）


-- 練習 3：作答紀錄中，「從來沒答對過」的題目
--        提示：答對次數 SUM(is_correct) = 0


-- 練習 4：只看 exam_id 1～3 的題目，找出題數大於等於 6 的考試
--        想一想：exam_id 的條件應該放 WHERE 還是 HAVING？


-- 練習 5：哪個答案選項（A/B/C/D）出現超過 7 次？
--        不要算入還沒輸入答案的題目


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT topic_id, COUNT(*) AS 題數
FROM question_topics
GROUP BY topic_id
HAVING COUNT(*) >= 4;

-- 練習 2
SELECT exam_id, MAX(score)
FROM questions
GROUP BY exam_id
HAVING MAX(score) > 2;   -- 只有第 1 份考試

-- 練習 3
SELECT question_id, COUNT(*) AS 作答次數
FROM practice_log
GROUP BY question_id
HAVING SUM(is_correct) = 0;

-- 練習 4：exam_id 的條件跟彙總無關，放 WHERE
SELECT exam_id, COUNT(*)
FROM questions
WHERE exam_id BETWEEN 1 AND 3
GROUP BY exam_id
HAVING COUNT(*) >= 6;

-- 練習 5
SELECT answer, COUNT(*)
FROM questions
WHERE answer IS NOT NULL
GROUP BY answer
HAVING COUNT(*) > 7;

*/
