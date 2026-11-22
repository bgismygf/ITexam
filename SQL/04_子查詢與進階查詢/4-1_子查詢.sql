-- =====================================================================
-- 4-1 子查詢
-- =====================================================================

-- 範例 1：配分高於平均的題目（純量子查詢）
SELECT question_id, score FROM questions
WHERE score > (SELECT AVG(score) FROM questions);

-- 範例 2：配分最高的題目（解決 2-1 課的問題）
SELECT question_id, content, score FROM questions
WHERE score = (SELECT MAX(score) FROM questions);

-- 範例 3：作答過的題目（多列子查詢 + IN）
SELECT question_id, content FROM questions
WHERE question_id IN (SELECT question_id FROM practice_log);

-- 範例 4：113 年的題目（子查詢寫法）
SELECT question_id, content FROM questions
WHERE exam_id IN (SELECT exam_id FROM exams WHERE year = 113);

-- 範例 5：FROM 子查詢：每份考試的平均題數
SELECT AVG(題數) AS 平均題數
FROM (SELECT exam_id, COUNT(*) AS 題數
      FROM questions
      GROUP BY exam_id) AS t;

-- 範例 6：SELECT 子查詢：每題配分與平均的差距
SELECT question_id, score,
       score - (SELECT AVG(score) FROM questions) AS 與平均差距
FROM questions
WHERE exam_id = 1;

-- 範例 7：解決 2-4 課的同分問題：出現次數最多的答案（同分全部列出）
SELECT answer, COUNT(*) AS 題數
FROM questions
WHERE answer IS NOT NULL
GROUP BY answer
HAVING COUNT(*) = (SELECT MAX(cnt)
                   FROM (SELECT COUNT(*) AS cnt
                         FROM questions
                         WHERE answer IS NOT NULL
                         GROUP BY answer));


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：找出題數（question_count）最多的考試


-- 練習 2：找出屬於「資料結構」章節的題目內容
--        （用子查詢，不用 JOIN；提示：可能需要兩層子查詢）


-- 練習 3：找出最近一次作答的那道題目的內容


-- 練習 4：計算每個章節題數的「平均值」（先算每章題數，再平均）


-- 練習 5：列出作答次數「高於平均作答次數」的題目
--        （平均作答次數 = 有被作答過的題目，平均每題被作答幾次）


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT * FROM exams
WHERE question_count = (SELECT MAX(question_count) FROM exams);

-- 練習 2
SELECT question_id, content FROM questions
WHERE question_id IN (
    SELECT question_id FROM question_topics
    WHERE topic_id = (SELECT topic_id FROM topics WHERE name = '資料結構')
);

-- 練習 3
SELECT content FROM questions
WHERE question_id = (SELECT question_id FROM practice_log
                     ORDER BY answered_at DESC LIMIT 1);

-- 練習 4
SELECT AVG(cnt) FROM (
    SELECT topic_id, COUNT(*) AS cnt FROM question_topics GROUP BY topic_id
) AS t;

-- 練習 5
SELECT question_id, COUNT(*) AS 作答次數
FROM practice_log
GROUP BY question_id
HAVING COUNT(*) > (
    SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM practice_log GROUP BY question_id)
);
-- 結果：第 8 題（2 次），平均約 1.11 次

*/
