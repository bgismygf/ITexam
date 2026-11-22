-- =====================================================================
-- 5-5 ALTER、DROP、TRUNCATE
-- =====================================================================

-- 準備練習表
DROP TABLE IF EXISTS my_exams;
CREATE TABLE my_exams AS SELECT * FROM exams;

PRAGMA table_info(my_exams);

-- 範例 1：新增欄位（既有資料的新欄位會是 NULL，或 DEFAULT 值）
ALTER TABLE my_exams ADD COLUMN exam_date TEXT;
ALTER TABLE my_exams ADD COLUMN note TEXT DEFAULT '無';

SELECT * FROM my_exams;

-- 範例 2：更新新欄位的資料
UPDATE my_exams SET exam_date = (year + 1911) || '-10-18';

-- 範例 3：欄位改名
ALTER TABLE my_exams RENAME COLUMN note TO remark;

PRAGMA table_info(my_exams);

-- 範例 4：刪除欄位
ALTER TABLE my_exams DROP COLUMN remark;

-- 範例 5：表改名
DROP TABLE IF EXISTS my_exam_list;
ALTER TABLE my_exams RENAME TO my_exam_list;

SELECT * FROM my_exam_list;

-- 範例 6：SQLite 沒有 TRUNCATE（預期錯誤）
-- 預期錯誤
TRUNCATE TABLE my_exam_list;

-- 範例 7：用 DELETE 清空資料，表還在
DELETE FROM my_exam_list;
SELECT COUNT(*) FROM my_exam_list;   -- 0
PRAGMA table_info(my_exam_list);     -- 結構還在

-- 範例 8：DROP 把整張表刪掉
DROP TABLE my_exam_list;

-- 預期錯誤
SELECT * FROM my_exam_list;          -- 表不存在了


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：複製 topics 為 my_topics，新增一個欄位 weight（整數，預設 1），
--        代表該章節的重要程度


-- 練習 2：把「資料庫」和「網路」章節的 weight 改成 3


-- 練習 3：把 weight 欄位改名為 importance


-- 練習 4：刪除 my_topics 表


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
DROP TABLE IF EXISTS my_topics;
CREATE TABLE my_topics AS SELECT * FROM topics;
ALTER TABLE my_topics ADD COLUMN weight INTEGER DEFAULT 1;
SELECT * FROM my_topics;

-- 練習 2
UPDATE my_topics SET weight = 3 WHERE name IN ('資料庫', '網路');

-- 練習 3
ALTER TABLE my_topics RENAME COLUMN weight TO importance;
SELECT * FROM my_topics;

-- 練習 4
DROP TABLE my_topics;

*/
