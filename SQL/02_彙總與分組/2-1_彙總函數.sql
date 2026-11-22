-- =====================================================================
-- 2-1 彙總函數
-- =====================================================================

-- 範例 1：五個基本彙總函數
SELECT
    COUNT(*)   AS 題數,
    SUM(score) AS 總配分,
    AVG(score) AS 平均配分,
    MAX(score) AS 最高配分,
    MIN(score) AS 最低配分
FROM questions;

-- 範例 2：COUNT 的三種寫法
SELECT
    COUNT(*)               AS 全部列數,
    COUNT(answer)          AS 有答案的題數,
    COUNT(DISTINCT answer) AS 答案種類數
FROM questions;

-- 範例 3：搭配 WHERE，第 1 份考試有幾題、總分多少
SELECT COUNT(*), SUM(score)
FROM questions
WHERE exam_id = 1;

-- 範例 4：MAX / MIN 用在文字日期上
SELECT MIN(answered_at) AS 第一次作答, MAX(answered_at) AS 最近一次作答
FROM practice_log;

-- 範例 5：答對率（注意乘以 1.0 避免整數除法）
SELECT
    SUM(is_correct)              AS 答對次數,
    COUNT(*)                     AS 作答次數,
    SUM(is_correct) * 1.0 / COUNT(*) AS 答對率
FROM practice_log;

-- 範例 6：整數除法陷阱
SELECT SUM(is_correct) / COUNT(*) AS 錯誤的答對率
FROM practice_log;

-- 範例 7：沒有符合的資料時，COUNT 是 0，SUM 是 NULL
SELECT COUNT(*), SUM(score) FROM questions WHERE exam_id = 999;

-- 範例 8：AVG 忽略 NULL 的示範
-- （FROM 後面的括號是「子查詢」，用來臨時產生 80、NULL、100 三筆資料，第 4 單元會教）
SELECT AVG(x), AVG(COALESCE(x, 0))
FROM (SELECT 80 AS x UNION ALL SELECT NULL UNION ALL SELECT 100);


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：題庫共有幾份考試？


-- 練習 2：exam_id = 2 的考試，總配分是多少？


-- 練習 3：計算所有考試的平均題數（question_count）


-- 練習 4：作答紀錄中，總共答錯幾次？（用 SUM 或 COUNT 都可以，試試兩種寫法）


-- 練習 5：作答紀錄中，總共有幾道「不同的」題目被作答過？


-- 練習 6：題庫中，最早和最晚的考試年度各是多少？


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT COUNT(*) FROM exams;   -- 5

-- 練習 2
SELECT SUM(score) FROM questions WHERE exam_id = 2;   -- 14

-- 練習 3
SELECT AVG(question_count) FROM exams;   -- 6.0

-- 練習 4
SELECT COUNT(*) FROM practice_log WHERE is_correct = 0;   -- 5
SELECT SUM(1 - is_correct) FROM practice_log;             -- 5

-- 練習 5
SELECT COUNT(DISTINCT question_id) FROM practice_log;   -- 9（第 8 題被作答 2 次）

-- 練習 6
SELECT MIN(year), MAX(year) FROM exams;   -- 110、113

*/
