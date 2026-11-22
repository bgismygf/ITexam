-- =====================================================================
-- 5-6 參考完整性與 ON DELETE CASCADE
-- =====================================================================

PRAGMA foreign_keys = ON;

-- 準備：三組父子表，分別設定不同的 ON DELETE 動作
DROP TABLE IF EXISTS my_child_restrict;
DROP TABLE IF EXISTS my_child_cascade;
DROP TABLE IF EXISTS my_child_setnull;
DROP TABLE IF EXISTS my_parent;

CREATE TABLE my_parent (
    exam_id INTEGER PRIMARY KEY,
    name    TEXT
);

CREATE TABLE my_child_restrict (
    question_id INTEGER PRIMARY KEY,
    exam_id     INTEGER REFERENCES my_parent(exam_id)          -- 預設 NO ACTION
);

CREATE TABLE my_child_cascade (
    question_id INTEGER PRIMARY KEY,
    exam_id     INTEGER REFERENCES my_parent(exam_id) ON DELETE CASCADE
);

CREATE TABLE my_child_setnull (
    question_id INTEGER PRIMARY KEY,
    exam_id     INTEGER REFERENCES my_parent(exam_id) ON DELETE SET NULL
);

INSERT INTO my_parent VALUES (1, '考試一'), (2, '考試二'), (3, '考試三');
INSERT INTO my_child_restrict VALUES (101, 1), (102, 1);
INSERT INTO my_child_cascade  VALUES (201, 2), (202, 2);
INSERT INTO my_child_setnull  VALUES (301, 3), (302, 3);

-- 範例 1：NO ACTION：考試一還有題目，刪除失敗（預期錯誤）
-- 預期錯誤
DELETE FROM my_parent WHERE exam_id = 1;

-- 範例 2：CASCADE：刪除考試二，題目 201、202 也一起被刪除
DELETE FROM my_parent WHERE exam_id = 2;
SELECT * FROM my_child_cascade;      -- 空的

-- 範例 3：SET NULL：刪除考試三，題目 301、302 的 exam_id 變成 NULL
DELETE FROM my_parent WHERE exam_id = 3;
SELECT * FROM my_child_setnull;      -- exam_id 是 NULL

-- 範例 4：原本的題庫是預設 NO ACTION，所以不能刪除還有題目的考試（預期錯誤）
-- 預期錯誤
DELETE FROM exams WHERE exam_id = 1;

-- 範例 5：外來鍵也會檢查新增：子表不能參照不存在的父表資料（預期錯誤）
-- 預期錯誤
INSERT INTO my_child_cascade VALUES (203, 999);

-- 清除練習表（要先刪子表，再刪父表）
DROP TABLE my_child_restrict;
DROP TABLE my_child_cascade;
DROP TABLE my_child_setnull;
DROP TABLE my_parent;


-- =====================================================================
-- 本單元總練習：親手建出題庫
-- =====================================================================
-- 不看答案，用 my_ 開頭的表名，建立以下 6 張表（含主鍵、外來鍵、NOT NULL、UNIQUE、CHECK）：
--
--   my_exams           考試：編號、年度、招考單位、類別、科目、題數、是否倒扣（只能 0 或 1）
--   my_questions       題目：編號、所屬考試、題號、內容、配分（> 0）、答案（A～D 或 NULL）
--                            同一考試的題號不可重複；刪除考試時，題目一起刪除
--   my_options         選項：所屬題目、標籤（A～D）、內容；主鍵是（題目, 標籤）
--                            刪除題目時，選項一起刪除
--   my_topics          章節：編號、名稱（不可重複）
--   my_question_topics 題目-章節：主鍵是（題目, 章節）
--   my_practice_log    作答紀錄：編號、題目、作答時間（預設現在）、選擇、是否答對
--
-- 建好之後，各新增幾筆資料，並故意違反限制條件，確認會被擋下。
-- 參考答案：data/建立題庫.sql（原版沒有 CASCADE 和部分 CHECK，下面是加強版）


-- =====================================================================
-- 解答
-- =====================================================================
/*

DROP TABLE IF EXISTS my_practice_log;
DROP TABLE IF EXISTS my_question_topics;
DROP TABLE IF EXISTS my_options;
DROP TABLE IF EXISTS my_questions;
DROP TABLE IF EXISTS my_topics;
DROP TABLE IF EXISTS my_exams;

CREATE TABLE my_exams (
    exam_id        INTEGER PRIMARY KEY,
    year           INTEGER NOT NULL,
    organizer      TEXT    NOT NULL,
    category       TEXT    NOT NULL,
    subject        TEXT    NOT NULL,
    question_count INTEGER CHECK (question_count > 0),
    wrong_penalty  INTEGER NOT NULL DEFAULT 0 CHECK (wrong_penalty IN (0, 1))
);

CREATE TABLE my_questions (
    question_id INTEGER PRIMARY KEY,
    exam_id     INTEGER NOT NULL REFERENCES my_exams(exam_id) ON DELETE CASCADE,
    question_no INTEGER NOT NULL,
    content     TEXT    NOT NULL,
    score       REAL    NOT NULL CHECK (score > 0),
    answer      TEXT    CHECK (answer IN ('A', 'B', 'C', 'D')),
    UNIQUE (exam_id, question_no)
);

CREATE TABLE my_options (
    question_id INTEGER NOT NULL REFERENCES my_questions(question_id) ON DELETE CASCADE,
    label       TEXT    NOT NULL CHECK (label IN ('A', 'B', 'C', 'D')),
    content     TEXT    NOT NULL,
    PRIMARY KEY (question_id, label)
);

CREATE TABLE my_topics (
    topic_id INTEGER PRIMARY KEY,
    name     TEXT NOT NULL UNIQUE
);

CREATE TABLE my_question_topics (
    question_id INTEGER NOT NULL REFERENCES my_questions(question_id) ON DELETE CASCADE,
    topic_id    INTEGER NOT NULL REFERENCES my_topics(topic_id),
    PRIMARY KEY (question_id, topic_id)
);

CREATE TABLE my_practice_log (
    log_id      INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL REFERENCES my_questions(question_id),
    answered_at TEXT    NOT NULL DEFAULT (datetime('now', 'localtime')),
    chosen      TEXT    NOT NULL,
    is_correct  INTEGER NOT NULL CHECK (is_correct IN (0, 1))
);

-- 測試資料
INSERT INTO my_exams VALUES (1, 114, '自編範例', '資訊', '計算機原理', 1, 0);
INSERT INTO my_questions VALUES (1, 1, 1, '測試題', 2, 'A');
INSERT INTO my_options VALUES (1, 'A', '甲'), (1, 'B', '乙'), (1, 'C', '丙'), (1, 'D', '丁');

-- 預期錯誤
INSERT INTO my_exams VALUES (2, 114, '自編範例', '資訊', '網路概論', 1, 2);   -- wrong_penalty 只能 0/1
-- 預期錯誤
INSERT INTO my_options VALUES (1, 'E', '戊');                                   -- label 只能 A～D

-- CASCADE 測試：刪除考試，題目和選項一起刪除
DELETE FROM my_exams WHERE exam_id = 1;
SELECT COUNT(*) FROM my_options;   -- 0

-- 清除
DROP TABLE my_practice_log;
DROP TABLE my_question_topics;
DROP TABLE my_options;
DROP TABLE my_questions;
DROP TABLE my_topics;
DROP TABLE my_exams;

*/
