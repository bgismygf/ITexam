-- =====================================================================
-- 6-7 反正規化：加一個彙總欄位，並看看要怎麼維持一致性
-- =====================================================================

DROP TABLE IF EXISTS my_exams;
CREATE TABLE my_exams AS SELECT * FROM exams;

-- 範例 1：加一個「作答次數」的冗餘欄位
ALTER TABLE my_exams ADD COLUMN practice_count INTEGER DEFAULT 0;

-- 範例 2：初次計算
UPDATE my_exams
SET practice_count = (
    SELECT COUNT(*)
    FROM practice_log p
    JOIN questions q ON p.question_id = q.question_id
    WHERE q.exam_id = my_exams.exam_id
);

-- 現在查詢不用 JOIN 了
SELECT exam_id, year, subject, practice_count FROM my_exams;

-- 範例 3：⚠️ 一致性問題：新增作答紀錄後，冗餘欄位不會自動更新
DROP TABLE IF EXISTS my_log;
CREATE TABLE my_log AS SELECT * FROM practice_log;
INSERT INTO my_log VALUES (11, 26, '2026-11-08 20:00', 'C', 1);   -- exam 5 的題目

-- 正規化的算法（即時、正確）
SELECT q.exam_id, COUNT(*)
FROM my_log p JOIN questions q ON p.question_id = q.question_id
GROUP BY q.exam_id;

-- 冗餘欄位（還是舊的值，exam 5 仍然是 0）
SELECT exam_id, practice_count FROM my_exams;

-- 範例 4：檢查冗餘欄位是否一致的 SQL（工作上做資料稽核常用）
SELECT e.exam_id, e.practice_count AS 冗餘欄位,
       (SELECT COUNT(*) FROM my_log p JOIN questions q ON p.question_id = q.question_id
        WHERE q.exam_id = e.exam_id) AS 實際值
FROM my_exams e
WHERE e.practice_count <> (SELECT COUNT(*) FROM my_log p JOIN questions q
                           ON p.question_id = q.question_id
                           WHERE q.exam_id = e.exam_id);

-- 9-3 課會學用 Trigger 自動維持一致性

DROP TABLE my_exams;
DROP TABLE my_log;
