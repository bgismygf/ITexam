-- =====================================================================
-- 10-2 CSV 匯入、資料清理（ETL）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 步驟 1：Extract：匯入暫存表 import_raw
-- 方法 A（建議）：用 DB Browser 的 File → Import → Table from CSV file，
--                匯入 data/新題目_待匯入.csv，表名取 import_raw，然後跳到步驟 2
-- 方法 B：直接執行下面這段，效果跟匯入 CSV 一樣
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS import_raw;
CREATE TABLE import_raw (
    "年度" TEXT, "科目" TEXT, "題號" TEXT, "題目" TEXT,
    "選項A" TEXT, "選項B" TEXT, "選項C" TEXT, "選項D" TEXT, "答案" TEXT, "配分" TEXT
);
INSERT INTO import_raw VALUES
('114年','計算機原理','1','  關聯式資料庫中，用來建立表與表之間關聯的是？ ','主鍵','外來鍵','索引','檢視表','b','2'),
('114年','計算機原理','2','SQL 中用來排序的子句是？','GROUP BY','HAVING','ORDER BY','WHERE','Ｃ','2'),
('114年','計算機原理','3','下列何者屬於 DCL？','GRANT','SELECT','CREATE','COMMIT',' A ','2'),
('114年','計算機原理','4','交易的四大特性中，D 代表？','Durability','Distribution','Duplication','Dependency','','2'),
('114年','計算機原理','2','SQL 中用來排序的子句是？','GROUP BY','HAVING','ORDER BY','WHERE','Ｃ','2'),
('114','網路概論','1','TCP/IP 模型中，HTTP 屬於哪一層？','應用層','傳輸層','網路層','鏈結層','A','2'),
('114','網路概論','2','下列哪一個是私有 IP 位址？','8.8.8.8','192.168.1.1','140.112.1.1','1.1.1.1','B','二'),
('114','網路概論','3','DNS 預設使用的連接埠為？','21','25','53','80','E','2');

SELECT * FROM import_raw;

-- ---------------------------------------------------------------------
-- 步驟 2：Transform：清理
-- 建立清理後的暫存表，每個欄位套用清理規則
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS import_clean;
CREATE TABLE import_clean AS
SELECT
    CAST(replace(trim("年度"), '年', '') AS INTEGER)            AS year,
    trim("科目")                                                AS subject,
    CAST(trim("題號") AS INTEGER)                               AS question_no,
    trim("題目")                                                AS content,
    trim("選項A") AS opt_a, trim("選項B") AS opt_b,
    trim("選項C") AS opt_c, trim("選項D") AS opt_d,
    NULLIF(upper(replace(replace(replace(replace(trim("答案"),
        'Ａ', 'A'), 'Ｂ', 'B'), 'Ｃ', 'C'), 'Ｄ', 'D')), '')       AS answer,
    trim("配分")                                                AS score_text
FROM import_raw;

SELECT * FROM import_clean;

-- ---------------------------------------------------------------------
-- 步驟 3：驗證：找出有問題的資料
-- ---------------------------------------------------------------------

-- 3-1 重複資料（同一年、同科目、同題號）
SELECT year, subject, question_no, COUNT(*) AS 次數
FROM import_clean
GROUP BY year, subject, question_no
HAVING COUNT(*) > 1;

-- 3-2 答案不合法（不是 A～D，但允許 NULL＝待補）
SELECT * FROM import_clean
WHERE answer IS NOT NULL AND answer NOT IN ('A', 'B', 'C', 'D');

-- 3-3 配分不是數字
SELECT * FROM import_clean
WHERE NOT (score_text GLOB '[0-9]*' AND score_text NOT GLOB '*[^0-9.]*');

-- 3-4 彙整成「問題清單」，可以匯出成 CSV 退回給資料提供者
SELECT year, subject, question_no, '答案不合法：' || answer AS 問題
FROM import_clean WHERE answer IS NOT NULL AND answer NOT IN ('A','B','C','D')
UNION ALL
SELECT year, subject, question_no, '配分不是數字：' || score_text
FROM import_clean WHERE NOT (score_text GLOB '[0-9]*' AND score_text NOT GLOB '*[^0-9.]*')
UNION ALL
SELECT year, subject, question_no, '答案空白（待補）'
FROM import_clean WHERE answer IS NULL
UNION ALL
SELECT year, subject, question_no, '重複 ' || COUNT(*) || ' 次'
FROM import_clean GROUP BY year, subject, question_no HAVING COUNT(*) > 1
ORDER BY 1, 2, 3;

-- ---------------------------------------------------------------------
-- 步驟 4：Load：只把「合格」的資料寫入正式資料表
-- 這裡寫入練習用的 my_ 表，確認流程正確後，可以改成寫入真正的 exams / questions / options
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS my_exams;
DROP TABLE IF EXISTS my_questions;
DROP TABLE IF EXISTS my_options;
CREATE TABLE my_exams     AS SELECT * FROM exams;
CREATE TABLE my_questions AS SELECT * FROM questions;
CREATE TABLE my_options   AS SELECT * FROM options;

-- 合格資料：去除重複，排除答案不合法、配分不是數字的
DROP VIEW IF EXISTS v_import_ok;
CREATE VIEW v_import_ok AS
SELECT DISTINCT year, subject, question_no, content, opt_a, opt_b, opt_c, opt_d, answer,
       CAST(score_text AS REAL) AS score
FROM import_clean
WHERE (answer IS NULL OR answer IN ('A', 'B', 'C', 'D'))
  AND score_text GLOB '[0-9]*' AND score_text NOT GLOB '*[^0-9.]*';

SELECT * FROM v_import_ok;

-- 4-1 新增考試（已存在的就不新增）
INSERT INTO my_exams (exam_id, year, organizer, category, subject, question_count, wrong_penalty)
SELECT (SELECT MAX(exam_id) FROM my_exams) + ROW_NUMBER() OVER (ORDER BY year, subject),
       year, '自編範例', '資訊', subject, COUNT(*), 0
FROM v_import_ok o
WHERE NOT EXISTS (SELECT 1 FROM my_exams e WHERE e.year = o.year AND e.subject = o.subject)
GROUP BY year, subject;

SELECT * FROM my_exams;

-- 4-2 新增題目
INSERT INTO my_questions (question_id, exam_id, question_no, content, score, answer)
SELECT (SELECT MAX(question_id) FROM my_questions) + ROW_NUMBER() OVER (ORDER BY e.exam_id, o.question_no),
       e.exam_id, o.question_no, o.content, o.score, o.answer
FROM v_import_ok o
JOIN my_exams e ON e.year = o.year AND e.subject = o.subject;

-- 4-3 新增選項：把一列四個選項「轉置」成四列（UNION ALL）
INSERT INTO my_options (question_id, label, content)
SELECT q.question_id, x.label, x.content
FROM my_questions q
JOIN my_exams e ON q.exam_id = e.exam_id
JOIN (
    SELECT year, subject, question_no, 'A' AS label, opt_a AS content FROM v_import_ok
    UNION ALL SELECT year, subject, question_no, 'B', opt_b FROM v_import_ok
    UNION ALL SELECT year, subject, question_no, 'C', opt_c FROM v_import_ok
    UNION ALL SELECT year, subject, question_no, 'D', opt_d FROM v_import_ok
) x ON x.year = e.year AND x.subject = e.subject AND x.question_no = q.question_no;

-- 確認匯入結果
SELECT e.year, e.subject, q.question_no, q.content, q.answer, COUNT(o.label) AS 選項數
FROM my_questions q
JOIN my_exams e ON q.exam_id = e.exam_id
LEFT JOIN my_options o ON o.question_id = q.question_id
WHERE e.year = 114
GROUP BY q.question_id
ORDER BY e.subject, q.question_no;

-- ---------------------------------------------------------------------
-- 步驟 5：匯出：把結果匯出成 CSV
--   在上面最後一個查詢的結果表格上，用 DB Browser 的匯出功能存成 CSV，
--   或 File → Export → Table(s) as CSV file 選擇要匯出的表
-- ---------------------------------------------------------------------

-- 清除練習物件
DROP VIEW IF EXISTS v_import_ok;
DROP TABLE IF EXISTS import_raw;
DROP TABLE IF EXISTS import_clean;
DROP TABLE IF EXISTS my_exams;
DROP TABLE IF EXISTS my_questions;
DROP TABLE IF EXISTS my_options;


-- =====================================================================
-- 練習題
-- =====================================================================
-- 練習 1：修正 CSV 中有問題的資料（在 Excel 或 VS Code 中修改 data/新題目_待匯入.csv）：
--        第 4 題補上答案 A、網路概論第 2 題配分改成 2、第 3 題答案改成 C，
--        刪掉重複的那一列，重新匯入並執行一次，確認問題清單是空的
--
-- 練習 2：確認流程沒問題後，把步驟 4 的 my_exams / my_questions / my_options
--        改成正式的 exams / questions / options，把 114 年的題目真正匯入題庫
--        （記得先備份！5-2 課的 CREATE TABLE ... AS SELECT，或 9-6 課的方法）
