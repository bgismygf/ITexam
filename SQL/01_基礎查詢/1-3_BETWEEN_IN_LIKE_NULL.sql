-- =====================================================================
-- 1-3 BETWEEN、IN、LIKE、IS NULL
-- =====================================================================

-- 範例 1：BETWEEN，111～113 年的考試（包含 111 和 113）
SELECT * FROM exams
WHERE year BETWEEN 111 AND 113;

-- 範例 2：NOT BETWEEN
SELECT * FROM exams
WHERE year NOT BETWEEN 111 AND 113;

-- 範例 3：IN，exam_id 是 1、3、5 的考試
SELECT * FROM exams
WHERE exam_id IN (1, 3, 5);

-- 範例 4：NOT IN，答案不是 A 也不是 B 的題目
-- 注意：第 29 題 answer 是 NULL，它不會出現在結果中（1-6 課說明原因）
SELECT question_id, answer FROM questions
WHERE answer NOT IN ('A', 'B');

-- 範例 5：LIKE，題目含有「資料庫」
SELECT question_id, content FROM questions
WHERE content LIKE '%資料庫%';

-- 範例 6：LIKE，以「下列」開頭的題目
SELECT question_id, content FROM questions
WHERE content LIKE '下列%';

-- 範例 7：LIKE，選項內容剛好 2 個字元
SELECT * FROM options
WHERE content LIKE '__';

-- 範例 8：LIKE 在 SQLite 不分英文大小寫
SELECT question_id, content FROM questions
WHERE content LIKE '%http%';

-- 範例 9：IS NULL，還沒輸入答案的題目
SELECT question_id, content, answer FROM questions
WHERE answer IS NULL;

-- 範例 10：= NULL 永遠查不到（不會出錯，但結果是空的）
SELECT question_id, content, answer FROM questions
WHERE answer = NULL;

-- 範例 11：IS NOT NULL
SELECT COUNT(*) FROM questions
WHERE answer IS NOT NULL;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：查出 question_id 在 10 到 15 之間（含）的題目


-- 練習 2：查出答案是 'A' 或 'D' 的題目（用 IN）


-- 練習 3：查出題目內容含有「協定」的題目


-- 練習 4：查出選項內容以「O(」開頭的選項（時間複雜度相關）


-- 練習 5：查出題目內容以「？」結尾，而且含有「位址」的題目


-- 練習 6：查出 practice_log 中，2026-11-01 ~ 2026-11-03 的作答紀錄
--        提示：answered_at 是文字，像 '2026-11-03 19:40'，
--              BETWEEN '2026-11-01' AND '2026-11-03' 會漏掉 11/3 當天，為什麼？


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT * FROM questions WHERE question_id BETWEEN 10 AND 15;

-- 練習 2
SELECT * FROM questions WHERE answer IN ('A', 'D');

-- 練習 3
SELECT question_id, content FROM questions WHERE content LIKE '%協定%';

-- 練習 4
SELECT * FROM options WHERE content LIKE 'O(%';

-- 練習 5
SELECT question_id, content FROM questions
WHERE content LIKE '%？' AND content LIKE '%位址%';

-- 練習 6
-- '2026-11-03 19:40' 比 '2026-11-03' 長，文字比較時會被當成「比較大」，
-- 所以超出 BETWEEN 的上限。正確做法是用「小於隔天」：
SELECT * FROM practice_log
WHERE answered_at >= '2026-11-01' AND answered_at < '2026-11-04';
-- 💼 這是工作上處理日期時間非常常見的寫法

*/
