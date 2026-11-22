-- =====================================================================
-- 5-2 CREATE TABLE 與資料型態
-- ⚠️ 從這一單元開始會修改資料庫。執行完要按 Write Changes（Ctrl+S）才會存檔；
--    不想保留就按 Revert Changes。本單元的練習表都以 my_ 開頭，不會影響原本的題庫。
-- =====================================================================

-- 範例 1：建立讀書筆記表（先刪除舊的，讓這個檔案可以重複執行）
DROP TABLE IF EXISTS my_notes;

CREATE TABLE my_notes (
    note_id    INTEGER PRIMARY KEY,
    title      TEXT NOT NULL,
    content    TEXT,
    created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

-- 範例 2：查看剛建立的結構
PRAGMA table_info(my_notes);

-- 範例 3：IF NOT EXISTS：表已經存在，不會出錯
CREATE TABLE IF NOT EXISTS my_notes (note_id INTEGER PRIMARY KEY);

-- 範例 4：沒有 IF NOT EXISTS，表已存在就會出錯（預期錯誤）
-- 預期錯誤
CREATE TABLE my_notes (note_id INTEGER PRIMARY KEY);

-- 範例 5：CREATE TABLE AS SELECT：快速備份
DROP TABLE IF EXISTS my_questions_backup;
CREATE TABLE my_questions_backup AS SELECT * FROM questions;

SELECT COUNT(*) FROM my_questions_backup;

-- 範例 6：只複製結構、不複製資料（WHERE 條件永遠不成立）
DROP TABLE IF EXISTS my_exams_empty;
CREATE TABLE my_exams_empty AS SELECT * FROM exams WHERE 1 = 0;

SELECT COUNT(*) FROM my_exams_empty;

-- 範例 7：SQLite 的型態很寬鬆：INTEGER 欄位存文字也不會出錯
DROP TABLE IF EXISTS my_loose;
CREATE TABLE my_loose (n INTEGER);
INSERT INTO my_loose VALUES ('不是數字');
SELECT n, typeof(n) FROM my_loose;

-- 範例 8：STRICT 資料表（SQLite 3.37+）會嚴格檢查型態（預期錯誤）
DROP TABLE IF EXISTS my_strict;
CREATE TABLE my_strict (n INTEGER) STRICT;
-- 預期錯誤
INSERT INTO my_strict VALUES ('不是數字');


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：建立一張 my_study_plan（讀書計畫）表，包含：
--        plan_id（整數，主鍵）、topic_name（文字，不可空白）、
--        target_date（文字，目標完成日）、done（整數，預設 0）


-- 練習 2：用 CREATE TABLE AS SELECT，建立 my_network_questions，
--        內容是所有網路概論的題目（question_id、content、answer）


-- 練習 3：練習結束後，刪除本課建立的所有練習表
--        （my_notes、my_questions_backup、my_exams_empty、my_loose、my_strict、
--          my_study_plan、my_network_questions）


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
DROP TABLE IF EXISTS my_study_plan;
CREATE TABLE my_study_plan (
    plan_id     INTEGER PRIMARY KEY,
    topic_name  TEXT NOT NULL,
    target_date TEXT,
    done        INTEGER DEFAULT 0
);

-- 練習 2
DROP TABLE IF EXISTS my_network_questions;
CREATE TABLE my_network_questions AS
SELECT q.question_id, q.content, q.answer
FROM questions q
JOIN exams e ON q.exam_id = e.exam_id
WHERE e.subject = '網路概論';

SELECT * FROM my_network_questions;

-- 練習 3
DROP TABLE IF EXISTS my_notes;
DROP TABLE IF EXISTS my_questions_backup;
DROP TABLE IF EXISTS my_exams_empty;
DROP TABLE IF EXISTS my_loose;
DROP TABLE IF EXISTS my_strict;
DROP TABLE IF EXISTS my_study_plan;
DROP TABLE IF EXISTS my_network_questions;

*/
