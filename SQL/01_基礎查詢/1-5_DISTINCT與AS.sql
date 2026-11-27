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
--   '年' 是文字資料 → 單引號；"考試 年度" 是名稱（別名）→ 雙引號
SELECT year || '年' AS "考試 年度" FROM exams;

-- 範例 7-1：單引號和雙引號的差別
SELECT "year" FROM exams;   -- 雙引號是名稱：取出 year 欄位的值 110、111……
SELECT 'year' FROM exams;   -- 單引號是文字：每列都顯示「year」這四個字母

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


-- 練習 6：把每份考試顯示成「110年 計算機原理」的格式，不重複，
--        欄位名稱叫「考試 名稱」（中間有空白）


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

-- 練習 6
SELECT DISTINCT year || '年 ' || subject AS "考試 名稱"
FROM exams;
-- '年 ' 是文字（單引號，「年」後面有一個空白）；"考試 名稱" 是別名（雙引號）
-- 結果 5 列：110年 計算機原理、111年 計算機原理、112年 網路概論、
--            113年 計算機原理、113年 網路概論
-- （113 年的兩份考試科目不同，接起來的文字不一樣，所以 DISTINCT 不會去掉任何一列；
--   比較範例 7：只接年度時，兩個「113年」相同，DISTINCT 就會去掉一個）

*/
