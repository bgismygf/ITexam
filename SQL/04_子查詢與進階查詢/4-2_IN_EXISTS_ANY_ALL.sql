-- =====================================================================
-- 4-2 IN / EXISTS / ANY / ALL
-- =====================================================================

-- 範例 1：IN
SELECT question_id FROM questions
WHERE question_id IN (SELECT question_id FROM practice_log);

-- 範例 2：NOT IN（子查詢沒有 NULL 時正常）
SELECT question_id FROM questions
WHERE question_id NOT IN (SELECT question_id FROM practice_log);

-- 範例 3：⚠️ NOT IN 的 NULL 陷阱：子查詢中有 NULL，結果是 0 筆
SELECT answer FROM questions WHERE exam_id = 5;   -- 先看看：C, B, A, NULL, A

SELECT question_id, answer FROM questions
WHERE answer NOT IN (SELECT answer FROM questions WHERE exam_id = 5);

-- 範例 4：解法 1：子查詢排除 NULL
SELECT question_id, answer FROM questions
WHERE answer NOT IN (SELECT answer FROM questions
                     WHERE exam_id = 5 AND answer IS NOT NULL);

-- 範例 5：EXISTS：作答過的題目
SELECT q.question_id, q.content FROM questions q
WHERE EXISTS (SELECT 1 FROM practice_log p WHERE p.question_id = q.question_id);

-- 範例 6：NOT EXISTS：沒被作答過的題目
SELECT q.question_id, q.content FROM questions q
WHERE NOT EXISTS (SELECT 1 FROM practice_log p WHERE p.question_id = q.question_id);

-- 範例 7：ANY / ALL 的等價寫法（SQLite 不支援 ANY / ALL）
-- 「配分比第 2 份考試所有題目都高」的題目，等於 > ALL，改寫成 > MAX
SELECT question_id, score FROM questions
WHERE score > (SELECT MAX(score) FROM questions WHERE exam_id = 2);

-- 「年度比任何一份網路概論考試早」，等於 < ANY，改寫成 < MAX
SELECT * FROM exams
WHERE year < (SELECT MAX(year) FROM exams WHERE subject = '網路概論');

-- 在 MySQL / SQL Server / PostgreSQL 可以這樣寫（SQLite 會出錯）：
-- SELECT question_id, score FROM questions
-- WHERE score > ALL (SELECT score FROM questions WHERE exam_id = 2);


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：用 EXISTS 找出「有題目屬於它」的章節名稱


-- 練習 2：用 NOT EXISTS 找出「沒有任何一題答錯過」的考試
--        （包含沒被作答過的考試）
--        提示：考試 → 題目 → 答錯的作答紀錄


-- 練習 3：找出「配分比第 1 份考試任何一題都低」的題目
--        先寫出 ANY/ALL 版本（理解用），再改成 SQLite 可執行的版本


-- 練習 4：下面的查詢想找「從來沒被選過的選項標籤」，請預測結果並說明
--        SELECT DISTINCT label FROM options
--        WHERE label NOT IN (SELECT chosen FROM practice_log);


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT t.name FROM topics t
WHERE EXISTS (SELECT 1 FROM question_topics qt WHERE qt.topic_id = t.topic_id);

-- 練習 2
SELECT e.* FROM exams e
WHERE NOT EXISTS (
    SELECT 1
    FROM questions q
    JOIN practice_log p ON p.question_id = q.question_id
    WHERE q.exam_id = e.exam_id AND p.is_correct = 0
);
-- 結果：第 5 份考試（沒被作答過）

-- 練習 3
-- ANY 版本：WHERE score < ALL (SELECT score FROM questions WHERE exam_id = 1)
-- 「比任何一題都低」= 比全部都低 = < ALL = < MIN
SELECT question_id, score FROM questions
WHERE score < (SELECT MIN(score) FROM questions WHERE exam_id = 1);
-- 結果：0 筆（最低配分 1.5，沒有題目低於 1.5）

-- 練習 4
SELECT DISTINCT label FROM options
WHERE label NOT IN (SELECT chosen FROM practice_log);
-- chosen 欄位沒有 NULL（NOT NULL 限制），所以可以正常運作。
-- 作答紀錄選過 A、B、C，結果是 D。

*/
