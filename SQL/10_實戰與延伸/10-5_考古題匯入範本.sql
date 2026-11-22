-- =====================================================================
-- 10-5 考古題匯入範本：手動輸入一份真實考古題
-- 使用方式：
--   1. 複製這個檔案，改名為例如「112_計算機原理.sql」
--   2. 填入考試資訊、題目、選項、答案、章節
--   3. 在 DB Browser 執行，確認後 Write Changes
-- 題目很多時，建議改用 10-2 課的 CSV 匯入流程，比較有效率
-- =====================================================================

-- 先確認目前最大的編號，新的編號從這裡往後接
SELECT MAX(exam_id) FROM exams;
SELECT MAX(question_id) FROM questions;

-- ---------------------------------------------------------------------
-- 1. 考試資訊（把 100 改成「目前最大 exam_id + 1」）
-- ---------------------------------------------------------------------
-- INSERT INTO exams (exam_id, year, organizer, category, subject, question_count, wrong_penalty)
-- VALUES (100, 112, '經濟部', '資訊', '計算機原理', 50, 0);

-- ---------------------------------------------------------------------
-- 2. 題目（把 1001 改成「目前最大 question_id + 1」，依序往後）
-- ---------------------------------------------------------------------
-- INSERT INTO questions (question_id, exam_id, question_no, content, score, answer) VALUES
--     (1001, 100, 1, '第 1 題的題目內容', 2, 'B'),
--     (1002, 100, 2, '第 2 題的題目內容', 2, 'D');

-- ---------------------------------------------------------------------
-- 3. 選項
-- ---------------------------------------------------------------------
-- INSERT INTO options (question_id, label, content) VALUES
--     (1001, 'A', '選項 A'), (1001, 'B', '選項 B'), (1001, 'C', '選項 C'), (1001, 'D', '選項 D'),
--     (1002, 'A', '選項 A'), (1002, 'B', '選項 B'), (1002, 'C', '選項 C'), (1002, 'D', '選項 D');

-- ---------------------------------------------------------------------
-- 4. 章節分類（topic_id 參考下面的查詢結果；一題可以屬於多個章節）
-- ---------------------------------------------------------------------
SELECT * FROM topics;

-- INSERT INTO question_topics (question_id, topic_id) VALUES
--     (1001, 1),
--     (1002, 4);

-- 如果需要新的章節：
-- INSERT INTO topics (name) VALUES ('雲端運算');

-- ---------------------------------------------------------------------
-- 5. 檢查
-- ---------------------------------------------------------------------
-- 每題是否都有 4 個選項
SELECT q.question_id, COUNT(o.label) AS 選項數
FROM questions q LEFT JOIN options o ON q.question_id = o.question_id
GROUP BY q.question_id
HAVING COUNT(o.label) <> 4;

-- 每題是否都有分類
SELECT q.question_id FROM questions q
WHERE NOT EXISTS (SELECT 1 FROM question_topics qt WHERE qt.question_id = q.question_id);

-- 題數是否與 question_count 一致
SELECT e.exam_id, e.question_count, COUNT(q.question_id) AS 實際題數
FROM exams e LEFT JOIN questions q ON e.exam_id = q.exam_id
GROUP BY e.exam_id
HAVING e.question_count <> COUNT(q.question_id);
