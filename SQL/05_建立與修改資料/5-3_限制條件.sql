-- =====================================================================
-- 5-3 限制條件
-- 標示「預期錯誤」的句子，執行後出現錯誤訊息是正常的，請閱讀錯誤訊息的內容
-- =====================================================================

PRAGMA foreign_keys = ON;   -- SQLite 要開啟才會檢查外來鍵

-- 建立一張有各種限制條件的練習表
DROP TABLE IF EXISTS my_questions;

CREATE TABLE my_questions (
    question_id INTEGER PRIMARY KEY,
    exam_id     INTEGER NOT NULL REFERENCES exams(exam_id),
    question_no INTEGER NOT NULL,
    content     TEXT    NOT NULL,
    score       REAL    NOT NULL DEFAULT 2 CHECK (score > 0),
    answer      TEXT    CONSTRAINT chk_answer CHECK (answer IN ('A', 'B', 'C', 'D')),
    UNIQUE (exam_id, question_no)
);

-- ✅ 正常新增
INSERT INTO my_questions (question_id, exam_id, question_no, content, score, answer)
VALUES (1, 1, 1, '測試題目一', 2, 'A');

-- ✅ 沒給 score，會使用 DEFAULT 2；沒給 question_id，會自動編號
INSERT INTO my_questions (exam_id, question_no, content, answer)
VALUES (1, 2, '測試題目二', 'B');

SELECT * FROM my_questions;

-- ❌ PRIMARY KEY 重複
-- 預期錯誤
INSERT INTO my_questions VALUES (1, 1, 3, '主鍵重複', 2, 'A');

-- ❌ NOT NULL：content 是 NULL
-- 預期錯誤
INSERT INTO my_questions (exam_id, question_no, content) VALUES (1, 3, NULL);

-- ❌ UNIQUE：同一份考試的題號重複
-- 預期錯誤
INSERT INTO my_questions (exam_id, question_no, content) VALUES (1, 1, '題號重複');

-- ❌ CHECK：答案不是 A～D
-- 預期錯誤
INSERT INTO my_questions (exam_id, question_no, content, answer) VALUES (1, 3, '答案錯誤', 'E');

-- ❌ CHECK：配分不是正數
-- 預期錯誤
INSERT INTO my_questions (exam_id, question_no, content, score) VALUES (1, 3, '配分錯誤', -1);

-- ❌ FOREIGN KEY：第 999 份考試不存在
-- 預期錯誤
INSERT INTO my_questions (exam_id, question_no, content) VALUES (999, 1, '考試不存在');

-- ✅ CHECK 遇到 NULL 會通過（answer 是 NULL）
INSERT INTO my_questions (exam_id, question_no, content, answer) VALUES (1, 3, '答案未定', NULL);

SELECT * FROM my_questions;

-- 查看原本題庫 questions 表的限制條件（建立時的 SQL）
SELECT sql FROM sqlite_master WHERE name = 'questions';


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：建立 my_members（會員）表：
--        member_id 主鍵；email 不可空白且不可重複；
--        name 不可空白；age 必須介於 15 到 100；
--        level 預設為 '一般'，只能是 '一般' 或 'VIP'


-- 練習 2：分別寫出一句「成功」的 INSERT，以及會違反各項限制的 INSERT，
--        觀察錯誤訊息


-- 練習 3：練習結束後刪除 my_questions 和 my_members


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
DROP TABLE IF EXISTS my_members;
CREATE TABLE my_members (
    member_id INTEGER PRIMARY KEY,
    email     TEXT NOT NULL UNIQUE,
    name      TEXT NOT NULL,
    age       INTEGER CHECK (age BETWEEN 15 AND 100),
    level     TEXT NOT NULL DEFAULT '一般' CHECK (level IN ('一般', 'VIP'))
);

-- 練習 2
INSERT INTO my_members (email, name, age) VALUES ('a@example.com', '小明', 25);   -- 成功
SELECT * FROM my_members;
-- 預期錯誤
INSERT INTO my_members (email, name, age) VALUES ('a@example.com', '小華', 30);   -- email 重複
-- 預期錯誤
INSERT INTO my_members (email, name, age) VALUES ('b@example.com', '小華', 10);   -- 年齡
-- 預期錯誤
INSERT INTO my_members (email, name, age, level) VALUES ('c@example.com', '小美', 20, '鑽石');   -- level
-- 預期錯誤
INSERT INTO my_members (email, age) VALUES ('d@example.com', 20);   -- name 是 NULL

-- 練習 3
DROP TABLE IF EXISTS my_questions;
DROP TABLE IF EXISTS my_members;

*/
