-- =====================================================================
-- 1-5 DISTINCT 與欄位別名 AS
-- =====================================================================

-- 範例 1：沒有 DISTINCT，會有重複
SELECT subject FROM exams;

-- 範例 2：DISTINCT 去除重複
SELECT DISTINCT subject FROM exams;

-- 範例 3：DISTINCT 作用在多個欄位的「組合」
SELECT DISTINCT year, subject FROM exams;

-- 範例 4：DISTINCT 會保留一個 NULL
SELECT DISTINCT answer FROM questions;

-- 範例 5：欄位別名
SELECT year AS 年度, subject AS 科目 FROM exams;

-- 範例 6：計算欄位加上別名
SELECT question_id AS 題目編號, score AS 配分, score * 2 AS 加倍配分
FROM questions;

-- 範例 7：別名有空白時用雙引號
SELECT year || '年' AS "考試 年度" FROM exams;

-- 範例 8：ORDER BY 可以使用別名
SELECT question_id, score * 2 AS double_score
FROM questions
ORDER BY double_score DESC
LIMIT 5;

-- 範例 9：資料表別名
SELECT q.question_id, q.content
FROM questions AS q
WHERE q.score > 2;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：查出題庫中出現過哪些年度（不重複），由舊到新排序


-- 練習 2：查出所有題目用到哪些不同的配分


-- 練習 3：查出作答紀錄中，有被作答過的題目編號（不重複）


-- 練習 4：查出每份考試，欄位顯示成「考試編號」「年度」「科目」「題數」


-- 練習 5：查出每題的編號，以及「答錯倒扣」時要扣的分數（配分的 1/4），
--        欄位名稱叫「倒扣分數」，依倒扣分數由大到小排序


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT DISTINCT year FROM exams ORDER BY year;

-- 練習 2
SELECT DISTINCT score FROM questions;

-- 練習 3
SELECT DISTINCT question_id FROM practice_log;

-- 練習 4
SELECT exam_id AS 考試編號, year AS 年度, subject AS 科目, question_count AS 題數
FROM exams;

-- 練習 5
SELECT question_id, score / 4 AS 倒扣分數
FROM questions
ORDER BY 倒扣分數 DESC;
-- 注意：score 是 REAL（小數），所以 score / 4 會得到小數。
-- 如果是兩個整數相除，例如 7 / 4，SQLite 會得到 1（整數除法），
-- 要寫成 7 / 4.0 或 7 * 1.0 / 4 才會得到 1.75

*/
