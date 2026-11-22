-- =====================================================================
-- 3-4 CROSS JOIN 與笛卡兒積
-- =====================================================================

-- 範例 1：exams（5 列）× topics（7 列）= 35 列
SELECT * FROM exams CROSS JOIN topics;

-- 範例 2：驗證列數
SELECT COUNT(*) FROM exams CROSS JOIN topics;

-- 範例 3：舊式寫法（逗號），沒有 WHERE 條件就是笛卡兒積
SELECT COUNT(*) FROM questions, exams;   -- 30 × 5 = 150

-- 範例 4：笛卡兒積 + 篩選 = INNER JOIN
SELECT COUNT(*) FROM questions q CROSS JOIN exams e
WHERE q.exam_id = e.exam_id;              -- 30

-- 範例 5：正當用途：每份考試 × 每個章節的出題數，
--        沒有出題的組合也要顯示 0（報表骨架）
SELECT e.exam_id, e.year, e.subject, t.name AS 章節,
       COUNT(qt.question_id) AS 題數
FROM exams e
CROSS JOIN topics t
LEFT JOIN questions q        ON q.exam_id = e.exam_id
LEFT JOIN question_topics qt ON qt.question_id = q.question_id
                            AND qt.topic_id = t.topic_id
GROUP BY e.exam_id, e.year, e.subject, t.topic_id, t.name
ORDER BY e.exam_id, t.topic_id;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：不執行，先算出 options × topics 會有幾列、幾欄，再執行驗證


-- 練習 2：產生 A、B、C、D 四個選項標籤 × 5 份考試的所有組合
--        提示：SELECT DISTINCT label FROM options 可以得到 A～D


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
-- options：120 列、3 欄；topics：7 列、2 欄
-- 結果：120 × 7 = 840 列，3 + 2 = 5 欄
SELECT COUNT(*) FROM options CROSS JOIN topics;

-- 練習 2
SELECT e.exam_id, l.label
FROM exams e
CROSS JOIN (SELECT DISTINCT label FROM options) l
ORDER BY e.exam_id, l.label;   -- 20 列

*/
