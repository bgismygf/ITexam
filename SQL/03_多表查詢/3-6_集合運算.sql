-- =====================================================================
-- 3-6 集合運算：UNION、INTERSECT、EXCEPT
-- 集合 A：作答過的題目；集合 B：屬於「資料庫」章節（topic_id = 1）的題目
-- =====================================================================

-- 先分別看看兩個集合
SELECT DISTINCT question_id FROM practice_log ORDER BY question_id;          -- A
SELECT question_id FROM question_topics WHERE topic_id = 1 ORDER BY question_id; -- B

-- 範例 1：UNION 聯集（去除重複）
SELECT question_id FROM practice_log
UNION
SELECT question_id FROM question_topics WHERE topic_id = 1
ORDER BY question_id;

-- 範例 2：UNION ALL（保留重複，第 8 題在 A 就出現兩次）
SELECT question_id FROM practice_log
UNION ALL
SELECT question_id FROM question_topics WHERE topic_id = 1
ORDER BY question_id;

-- 範例 3：INTERSECT 交集：作答過，而且屬於資料庫章節
SELECT question_id FROM practice_log
INTERSECT
SELECT question_id FROM question_topics WHERE topic_id = 1;

-- 範例 4：EXCEPT 差集：屬於資料庫章節，但還沒作答過
SELECT question_id FROM question_topics WHERE topic_id = 1
EXCEPT
SELECT question_id FROM practice_log;

-- 範例 5：把多個統計數字疊成一張報表
SELECT '考試份數' AS 項目, COUNT(*) AS 數量 FROM exams
UNION ALL
SELECT '題目數', COUNT(*) FROM questions
UNION ALL
SELECT '作答次數', COUNT(*) FROM practice_log;

-- 範例 6：❌ 欄位數不同，會出錯（預期錯誤）
-- 預期錯誤
SELECT question_id, content FROM questions
UNION
SELECT question_id FROM practice_log;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：列出屬於「網路」或「資訊安全」章節的題目編號（不重複）
--        用 UNION 寫，再想想有沒有不用 UNION 的寫法


-- 練習 2：列出同時屬於「網路」和「資訊安全」兩個章節的題目編號


-- 練習 3：列出所有還沒作答過的題目編號（用 EXCEPT）
--        跟 3-3 課的 LEFT JOIN + IS NULL 寫法比較看看


-- 練習 4：做一張報表，列出每份考試的「題數」和「作答次數」，格式如下：
--        項目           | exam_id | 數量
--        題數           |    1    |  6
--        作答次數       |    1    |  3
--        提示：兩個 GROUP BY 查詢用 UNION ALL 合併


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT question_id FROM question_topics WHERE topic_id = 4
UNION
SELECT question_id FROM question_topics WHERE topic_id = 7;
-- 不用 UNION 的寫法：
SELECT DISTINCT question_id FROM question_topics WHERE topic_id IN (4, 7);

-- 練習 2
SELECT question_id FROM question_topics WHERE topic_id = 4
INTERSECT
SELECT question_id FROM question_topics WHERE topic_id = 7;   -- 第 26 題

-- 練習 3
SELECT question_id FROM questions
EXCEPT
SELECT question_id FROM practice_log;

-- 練習 4
SELECT '題數' AS 項目, exam_id, COUNT(*) AS 數量
FROM questions
GROUP BY exam_id
UNION ALL
SELECT '作答次數', q.exam_id, COUNT(*)
FROM practice_log p
JOIN questions q ON p.question_id = q.question_id
GROUP BY q.exam_id
ORDER BY exam_id, 項目;

*/
