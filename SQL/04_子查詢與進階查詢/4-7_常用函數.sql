-- =====================================================================
-- 4-7 常用函數：字串、日期、型態轉換（SQLite 寫法）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 字串函數
-- ---------------------------------------------------------------------

-- 範例 1：長度、取子字串
SELECT content, length(content) AS 長度, substr(content, 1, 10) AS 前10字
FROM questions
WHERE exam_id = 1;

-- 範例 2：大小寫、取代、去空白
SELECT upper('select'), lower('SELECT'),
       replace('SQL 很難', '很難', '很簡單'),
       '[' || trim('   前後有空白   ') || ']';

-- 範例 3：找位置：題目中「？」出現在第幾個字
SELECT question_id, content, instr(content, '？') AS 問號位置
FROM questions
WHERE exam_id = 3;

-- 範例 4：題目太長時，只顯示前 15 個字 + '...'
SELECT question_id,
       CASE WHEN length(content) > 15
            THEN substr(content, 1, 15) || '...'
            ELSE content
       END AS 題目摘要
FROM questions;

-- ---------------------------------------------------------------------
-- 數值函數
-- ---------------------------------------------------------------------

-- 範例 5
SELECT ROUND(2.567, 1), ROUND(2.5), ABS(-3), 7 % 3;

-- ---------------------------------------------------------------------
-- 日期時間函數
-- ---------------------------------------------------------------------

-- 範例 6：現在時間、今天日期
SELECT datetime('now', 'localtime') AS 現在, date('now', 'localtime') AS 今天;

-- 範例 7：取出年、月、日、時
SELECT answered_at,
       strftime('%Y', answered_at) AS 年,
       strftime('%m', answered_at) AS 月,
       strftime('%d', answered_at) AS 日,
       strftime('%H', answered_at) AS 時
FROM practice_log;

-- 範例 8：日期加減
SELECT date('2026-11-01', '+7 days'), date('2026-11-01', '-1 month'),
       date('2026-11-01', 'start of month', '+1 month', '-1 day') AS 當月最後一天;

-- 範例 9：兩個日期相差幾天
SELECT julianday('2026-12-31') - julianday('2026-11-22') AS 相差天數;

-- 範例 10：民國年轉西元年
SELECT year AS 民國, year + 1911 AS 西元 FROM exams;

-- 範例 11：每個小時時段的作答次數（看自己幾點最常讀書）
SELECT strftime('%H', answered_at) AS 時段, COUNT(*) AS 次數
FROM practice_log
GROUP BY 時段;

-- ---------------------------------------------------------------------
-- 型態轉換
-- ---------------------------------------------------------------------

-- 範例 12：CAST
SELECT CAST('123' AS INTEGER) + 1, CAST(7 AS REAL) / 2, 7 / 2,
       CAST(113 AS TEXT) || '年';

-- 範例 13：文字排序 vs 數字排序
SELECT v FROM (SELECT '10' AS v UNION ALL SELECT '2' UNION ALL SELECT '1')
ORDER BY v;                          -- 文字：1, 10, 2

SELECT v FROM (SELECT '10' AS v UNION ALL SELECT '2' UNION ALL SELECT '1')
ORDER BY CAST(v AS INTEGER);         -- 數字：1, 2, 10


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：列出所有考試，顯示成「西元2021年 計算機原理」的格式


-- 練習 2：找出題目內容超過 25 個字的題目，依長度由長到短排序


-- 練習 3：列出所有作答紀錄，顯示日期（YYYY/MM/DD 格式）和星期幾
--        提示：strftime('%w', d) 回傳 0（星期日）～ 6（星期六）


-- 練習 4：計算每筆作答紀錄距離今天幾天，四捨五入到整數


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT '西元' || (year + 1911) || '年 ' || subject FROM exams;

-- 練習 2
SELECT question_id, content, length(content) AS 長度
FROM questions
WHERE length(content) > 25
ORDER BY 長度 DESC;

-- 練習 3
SELECT strftime('%Y/%m/%d', answered_at) AS 日期,
       CASE strftime('%w', answered_at)
           WHEN '0' THEN '日' WHEN '1' THEN '一' WHEN '2' THEN '二'
           WHEN '3' THEN '三' WHEN '4' THEN '四' WHEN '5' THEN '五'
           WHEN '6' THEN '六'
       END AS 星期
FROM practice_log;

-- 練習 4
SELECT log_id, answered_at,
       ROUND(julianday('now', 'localtime') - julianday(answered_at)) AS 距今天數
FROM practice_log;

*/
