-- =====================================================================
-- 9-6 備份與還原
-- =====================================================================

-- ---------------------------------------------------------------------
-- 方法 1：資料表層級的快速備份（修改資料前的好習慣）
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS questions_backup;
CREATE TABLE questions_backup AS SELECT * FROM questions;

-- 模擬改壞了：忘記寫 WHERE，所有答案都變成 A
-- （先在練習用的複製表上做，不要真的改 questions）
DROP TABLE IF EXISTS my_questions;
CREATE TABLE my_questions AS SELECT * FROM questions;
UPDATE my_questions SET answer = 'A';                 -- 💀 忘了 WHERE
SELECT answer, COUNT(*) FROM my_questions GROUP BY answer;

-- 從備份救回來：用備份表的值更新回去
UPDATE my_questions
SET answer = (SELECT b.answer FROM questions_backup b
              WHERE b.question_id = my_questions.question_id);

SELECT answer, COUNT(*) FROM my_questions GROUP BY answer;   -- 恢復了

DROP TABLE my_questions;
DROP TABLE questions_backup;

-- ---------------------------------------------------------------------
-- 方法 2：整個資料庫備份成另一個檔案（VACUUM INTO）
-- 把下面這句的 -- 拿掉再執行，路徑請改成你電腦上的位置
-- ⚠️ 在 DB Browser 中，要先按 Write Changes 存檔，而且 VACUUM 不能在交易中執行，
--    如果出現錯誤，請改用方法 3
-- ---------------------------------------------------------------------
-- VACUUM INTO 'C:/Users/KHUser/Desktop/資訊/SQL/data/exam_backup.db';

-- ---------------------------------------------------------------------
-- 方法 3：DB Browser 圖形介面
--   (1) 匯出成 SQL 檔：File → Export → Database to SQL file
--       產生的 .sql 檔包含所有 CREATE TABLE 和 INSERT，可以用來重建資料庫
--   (2) 直接複製檔案：先關閉 DB Browser（或 Close Database），
--       再到檔案總管複製 data\exam.db
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- 還原
--   SQL 檔：New Database → Execute SQL 開啟匯出的 .sql → 執行 → Write Changes
--   .db 檔：直接用 Open Database 打開備份檔，或把備份檔複製回來取代 exam.db
-- ---------------------------------------------------------------------

-- 練習：用方法 3 的 (1) 匯出整個題庫，再用 0-3 課的「還原方法」，
--       改用你匯出的 .sql 檔重建一個新的資料庫，確認資料都在
