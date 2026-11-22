-- =====================================================================
-- 9-3 Trigger 觸發程序
-- 注意：CREATE TRIGGER ... END; 是「一整句」，要整段反白後執行
-- 本課在練習表上操作
-- =====================================================================

-- 準備練習表
DROP TABLE IF EXISTS my_questions;
DROP TABLE IF EXISTS my_log;
DROP TABLE IF EXISTS my_audit;

CREATE TABLE my_questions AS SELECT * FROM questions;
ALTER TABLE my_questions ADD COLUMN attempts INTEGER DEFAULT 0;   -- 冗餘欄位：作答次數

CREATE TABLE my_log (
    log_id      INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    answered_at TEXT    DEFAULT (datetime('now', 'localtime')),
    chosen      TEXT    NOT NULL,
    is_correct  INTEGER
);

CREATE TABLE my_audit (
    audit_id   INTEGER PRIMARY KEY,
    table_name TEXT,
    action     TEXT,
    record_id  INTEGER,
    old_value  TEXT,
    new_value  TEXT,
    changed_at TEXT DEFAULT (datetime('now', 'localtime'))
);

-- ---------------------------------------------------------------------
-- 範例 1：BEFORE INSERT 不行改 NEW（SQLite 限制），改用 AFTER INSERT：
--         新增作答紀錄後，自動判斷對錯
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_log_check_answer;
CREATE TRIGGER trg_log_check_answer
AFTER INSERT ON my_log
FOR EACH ROW
BEGIN
    UPDATE my_log
    SET is_correct = CASE
        WHEN NEW.chosen = (SELECT answer FROM my_questions WHERE question_id = NEW.question_id)
        THEN 1 ELSE 0 END
    WHERE log_id = NEW.log_id;
END;

-- ---------------------------------------------------------------------
-- 範例 2：AFTER INSERT：自動更新題目的作答次數（解決 6-7 課的一致性問題）
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_log_count;
CREATE TRIGGER trg_log_count
AFTER INSERT ON my_log
FOR EACH ROW
BEGIN
    UPDATE my_questions SET attempts = attempts + 1
    WHERE question_id = NEW.question_id;
END;

-- 測試：只要新增作答（選了什麼），對錯和次數都自動處理
INSERT INTO my_log (question_id, chosen) VALUES (8, 'B');   -- 第 8 題答案是 B
INSERT INTO my_log (question_id, chosen) VALUES (8, 'A');
INSERT INTO my_log (question_id, chosen) VALUES (1, 'B');

SELECT * FROM my_log;                                            -- is_correct 自動填好
SELECT question_id, attempts FROM my_questions WHERE attempts > 0;   -- 次數自動更新

-- ---------------------------------------------------------------------
-- 範例 3：AFTER UPDATE + WHEN 條件：答案被修改時，記錄稽核紀錄
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_question_audit;
CREATE TRIGGER trg_question_audit
AFTER UPDATE OF answer ON my_questions
FOR EACH ROW
WHEN OLD.answer IS NOT NEW.answer          -- 答案真的有改變才記錄（IS NOT 可以正確比較 NULL）
BEGIN
    INSERT INTO my_audit (table_name, action, record_id, old_value, new_value)
    VALUES ('my_questions', 'UPDATE answer', NEW.question_id, OLD.answer, NEW.answer);
END;

UPDATE my_questions SET answer = 'C' WHERE question_id = 29;    -- NULL → C
UPDATE my_questions SET answer = 'D' WHERE question_id = 29;    -- C → D
UPDATE my_questions SET answer = 'D' WHERE question_id = 29;    -- 沒變，不記錄

SELECT * FROM my_audit;

-- ---------------------------------------------------------------------
-- 範例 4：BEFORE DELETE + RAISE：禁止刪除有作答紀錄的題目
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_question_no_delete;
CREATE TRIGGER trg_question_no_delete
BEFORE DELETE ON my_questions
FOR EACH ROW
WHEN EXISTS (SELECT 1 FROM my_log WHERE question_id = OLD.question_id)
BEGIN
    SELECT RAISE(ABORT, '這題已有作答紀錄，不能刪除');
END;

-- 預期錯誤
DELETE FROM my_questions WHERE question_id = 8;    -- 有作答紀錄，被擋下

DELETE FROM my_questions WHERE question_id = 30;   -- 沒有作答紀錄，可以刪除

-- ---------------------------------------------------------------------
-- 範例 5：INSTEAD OF：讓 View 可以更新
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS my_v_questions;
CREATE VIEW my_v_questions AS
SELECT q.question_id, e.year, e.subject, q.content, q.answer
FROM my_questions q JOIN exams e ON q.exam_id = e.exam_id;

DROP TRIGGER IF EXISTS trg_v_questions_update;
CREATE TRIGGER trg_v_questions_update
INSTEAD OF UPDATE OF answer ON my_v_questions
FOR EACH ROW
BEGIN
    UPDATE my_questions SET answer = NEW.answer WHERE question_id = NEW.question_id;
END;

UPDATE my_v_questions SET answer = 'A' WHERE question_id = 29;   -- 現在可以更新 View 了
SELECT * FROM my_v_questions WHERE question_id = 29;
SELECT * FROM my_audit;      -- 範例 3 的稽核 Trigger 也被觸發了（連鎖觸發）

-- 查看所有 Trigger
SELECT name, tbl_name FROM sqlite_master WHERE type = 'trigger';


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：在 my_log 建立 Trigger：刪除作答紀錄時，my_questions 的 attempts 自動減 1


-- 練習 2：建立 Trigger：新增作答時，如果 chosen 不是 A、B、C、D，就用 RAISE 拒絕
--        （提示：BEFORE INSERT + WHEN 條件）


-- 練習 3：建立 Trigger：刪除 my_log 的紀錄時，把被刪除的資料寫入 my_audit


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
DROP TRIGGER IF EXISTS trg_log_count_delete;
CREATE TRIGGER trg_log_count_delete
AFTER DELETE ON my_log
FOR EACH ROW
BEGIN
    UPDATE my_questions SET attempts = attempts - 1 WHERE question_id = OLD.question_id;
END;

DELETE FROM my_log WHERE log_id = 2;
SELECT question_id, attempts FROM my_questions WHERE question_id = 8;   -- 2 → 1

-- 練習 2
DROP TRIGGER IF EXISTS trg_log_check_chosen;
CREATE TRIGGER trg_log_check_chosen
BEFORE INSERT ON my_log
FOR EACH ROW
WHEN NEW.chosen NOT IN ('A', 'B', 'C', 'D')
BEGIN
    SELECT RAISE(ABORT, '選項只能是 A、B、C、D');
END;

-- 預期錯誤
INSERT INTO my_log (question_id, chosen) VALUES (1, 'E');

-- 練習 3
DROP TRIGGER IF EXISTS trg_log_audit_delete;
CREATE TRIGGER trg_log_audit_delete
AFTER DELETE ON my_log
FOR EACH ROW
BEGIN
    INSERT INTO my_audit (table_name, action, record_id, old_value)
    VALUES ('my_log', 'DELETE', OLD.log_id,
            'question=' || OLD.question_id || ', chosen=' || OLD.chosen);
END;

DELETE FROM my_log WHERE log_id = 3;
SELECT * FROM my_audit;

*/

-- 清除練習物件（刪除資料表時，其上的 Trigger 會一起刪除）
DROP VIEW IF EXISTS my_v_questions;
DROP TABLE IF EXISTS my_log;
DROP TABLE IF EXISTS my_audit;
DROP TABLE IF EXISTS my_questions;
