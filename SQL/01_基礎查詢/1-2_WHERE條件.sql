-- =====================================================================
-- 1-2 WHERE 條件
-- =====================================================================

-- 範例 1：113 年的考試
SELECT * FROM exams
WHERE year = 113;

-- 範例 2：科目是網路概論的考試（文字要加單引號）
SELECT * FROM exams
WHERE subject = '網路概論';

-- 範例 3：配分大於 2 分的題目
SELECT question_id, content, score
FROM questions
WHERE score > 2;

-- 範例 4：不是網路概論的考試
SELECT * FROM exams
WHERE subject <> '網路概論';

-- 範例 5：AND，兩個條件都要成立
SELECT * FROM exams
WHERE year = 113 AND subject = '網路概論';

-- 範例 6：OR，任一個條件成立即可
SELECT * FROM exams
WHERE year = 110 OR year = 113;

-- 範例 7：NOT
SELECT * FROM exams
WHERE NOT wrong_penalty = 1;

-- 範例 8：優先順序陷阱
-- 想要「113 年的計算機原理或網路概論」
-- ❌ 錯誤：會多出 112 年的網路概論
SELECT * FROM exams
WHERE year = 113 AND subject = '計算機原理' OR subject = '網路概論';

-- ✅ 正確：加括號
SELECT * FROM exams
WHERE year = 113 AND (subject = '計算機原理' OR subject = '網路概論');


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：查出 exam_id = 2 的所有題目（questions）


-- 練習 2：查出答案是 'C' 的題目的 question_id 和 content


-- 練習 3：查出「答錯會倒扣」（wrong_penalty = 1）的考試


-- 練習 4：查出 exam_id 是 1，而且配分大於等於 2 的題目


-- 練習 5：查出作答紀錄（practice_log）中答錯的紀錄（is_correct = 0）


-- 練習 6：查出 exam_id 是 3 或 5，而且答案是 'B' 的題目
--        （注意優先順序）


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT * FROM questions WHERE exam_id = 2;

-- 練習 2
SELECT question_id, content FROM questions WHERE answer = 'C';

-- 練習 3
SELECT * FROM exams WHERE wrong_penalty = 1;

-- 練習 4
SELECT * FROM questions WHERE exam_id = 1 AND score >= 2;

-- 練習 5
SELECT * FROM practice_log WHERE is_correct = 0;

-- 練習 6
SELECT * FROM questions
WHERE (exam_id = 3 OR exam_id = 5) AND answer = 'B';
-- 結果：第 14 題（網路層）、第 18 題（DNS）、第 27 題（DHCP）

*/
