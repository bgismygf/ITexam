-- =====================================================================
-- 8-1 索引原理：建立、查看、刪除索引
-- =====================================================================

-- 範例 1：查看題庫目前有哪些索引
-- （sqlite_autoindex_ 開頭的是建立 PRIMARY KEY / UNIQUE 時自動產生的）
SELECT name, tbl_name, sql FROM sqlite_master WHERE type = 'index';

-- 範例 2：查看某張表的索引
PRAGMA index_list(questions);

-- 範例 3：查看某個索引包含哪些欄位
PRAGMA index_info(sqlite_autoindex_questions_1);   -- UNIQUE (exam_id, question_no)

-- 範例 4：建立索引（在練習表上）
DROP TABLE IF EXISTS my_log;
CREATE TABLE my_log AS SELECT * FROM practice_log;

CREATE INDEX idx_my_log_question ON my_log(question_id);

PRAGMA index_list(my_log);

-- 範例 5：唯一索引：值重複會被拒絕
CREATE UNIQUE INDEX idx_my_log_unique ON my_log(question_id, answered_at);

-- 預期錯誤
INSERT INTO my_log VALUES (99, 1, '2026-11-01 20:10', 'B', 1);   -- 第 1 題同一時間已有紀錄

-- 範例 6：刪除索引
DROP INDEX idx_my_log_question;
DROP INDEX idx_my_log_unique;

PRAGMA index_list(my_log);

DROP TABLE my_log;

-- 下一課（8-3）會用 20 萬筆資料，實際比較有沒有索引的速度差異
