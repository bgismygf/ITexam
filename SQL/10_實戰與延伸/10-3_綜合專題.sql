-- =====================================================================
-- 10-3 綜合專題：任務 1～5 的 SQL
-- 先自己寫，再看解答
-- =====================================================================

-- 任務 1：依章節出題：隨機抽 3 題「資料庫」章節的題目


-- 任務 2：間隔複習：列出每題「最後一次練習的時間」，
--        沒練習過的排最前面，其次是最久沒練習的


-- 任務 3：模擬考：每份考試各隨機抽 2 題


-- 任務 4：每日進度報表：每天的作答數、答對數、答對率、累計作答數


-- 任務 5：熟練的題目：最近 2 次作答都答對的題目


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 任務 1
SELECT q.question_id, q.content
FROM questions q
JOIN question_topics qt ON q.question_id = qt.question_id
JOIN topics t           ON qt.topic_id = t.topic_id
WHERE t.name = '資料庫' AND q.answer IS NOT NULL
ORDER BY random()
LIMIT 3;

-- 任務 2
SELECT q.question_id, q.content, MAX(p.answered_at) AS 最後練習
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id
GROUP BY q.question_id, q.content
ORDER BY 最後練習 IS NOT NULL, 最後練習
LIMIT 10;
-- ORDER BY 最後練習 IS NOT NULL：NULL（沒練習過）的結果是 0，排在前面

-- 任務 3
WITH shuffled AS (
    SELECT q.*, ROW_NUMBER() OVER (PARTITION BY exam_id ORDER BY random()) AS rn
    FROM questions q
    WHERE answer IS NOT NULL
)
SELECT exam_id, question_id, content
FROM shuffled
WHERE rn <= 2
ORDER BY exam_id;

-- 任務 4
SELECT 日期, 作答數, 答對數,
       ROUND(答對數 * 100.0 / 作答數) || '%' AS 答對率,
       SUM(作答數) OVER (ORDER BY 日期)      AS 累計作答數
FROM (
    SELECT substr(answered_at, 1, 10) AS 日期,
           COUNT(*)        AS 作答數,
           SUM(is_correct) AS 答對數
    FROM practice_log
    GROUP BY substr(answered_at, 1, 10)
)
ORDER BY 日期;

-- 任務 5
WITH ranked AS (
    SELECT question_id, is_correct,
           ROW_NUMBER() OVER (PARTITION BY question_id ORDER BY answered_at DESC) AS rn
    FROM practice_log
)
SELECT question_id
FROM ranked
WHERE rn <= 2
GROUP BY question_id
HAVING COUNT(*) = 2 AND SUM(is_correct) = 2;
-- 範例資料中沒有連續答對 2 次的題目，結果為空；用刷題程式多練幾次再查看看

*/
