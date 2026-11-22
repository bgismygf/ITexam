-- =====================================================================
-- 5-4 INSERT、UPDATE、DELETE
-- 本課在「複製出來的練習表」上操作，不會動到原本的題庫
-- =====================================================================

-- 準備：複製題目和作答紀錄到練習表
DROP TABLE IF EXISTS my_questions;
CREATE TABLE my_questions AS SELECT * FROM questions;

DROP TABLE IF EXISTS my_log;
CREATE TABLE my_log (
    log_id      INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    answered_at TEXT    NOT NULL DEFAULT (datetime('now', 'localtime')),
    chosen      TEXT    NOT NULL,
    is_correct  INTEGER NOT NULL
);
INSERT INTO my_log SELECT * FROM practice_log;

-- ---------------------------------------------------------------------
-- INSERT
-- ---------------------------------------------------------------------

-- 範例 1：新增一筆作答紀錄（指定欄位；log_id 自動編號；answered_at 用預設值）
INSERT INTO my_log (question_id, chosen, is_correct)
VALUES (3, 'B', 1);

SELECT * FROM my_log ORDER BY log_id DESC LIMIT 3;

-- 範例 2：一次新增多筆
INSERT INTO my_log (question_id, answered_at, chosen, is_correct) VALUES
    (5, '2026-11-06 20:00', 'C', 1),
    (6, '2026-11-06 20:02', 'A', 0),
    (7, '2026-11-06 20:05', 'A', 1);

-- 範例 3：從查詢結果新增：把所有「還沒作答過」的 113 年題目，加入一筆「待練習」紀錄
--        （只是示範 INSERT ... SELECT，chosen 先填 '-'）
INSERT INTO my_log (question_id, answered_at, chosen, is_correct)
SELECT question_id, '2026-11-07 00:00', '-', 0
FROM my_questions
WHERE exam_id IN (4, 5)
  AND question_id NOT IN (SELECT question_id FROM my_log);

SELECT COUNT(*) FROM my_log;

-- ---------------------------------------------------------------------
-- UPDATE
-- ---------------------------------------------------------------------

-- 範例 4：安全流程：先 SELECT 確認
SELECT * FROM my_questions WHERE question_id = 29;

-- 再 UPDATE：補上第 29 題的答案
UPDATE my_questions SET answer = 'C' WHERE question_id = 29;

SELECT * FROM my_questions WHERE question_id = 29;

-- 範例 5：用原本的值計算：110 年的題目配分統一改成 2 分
SELECT question_id, score FROM my_questions WHERE exam_id = 1;
UPDATE my_questions SET score = 2 WHERE exam_id = 1;

-- 範例 6：一次改多個欄位
UPDATE my_questions
SET content = content || '（已修訂）', score = 3
WHERE question_id = 1;

SELECT * FROM my_questions WHERE question_id = 1;

-- 範例 7：UPDATE + 子查詢：重新計算 is_correct（依題目答案比對）
UPDATE my_log
SET is_correct = CASE
    WHEN chosen = (SELECT answer FROM my_questions q WHERE q.question_id = my_log.question_id)
    THEN 1 ELSE 0 END;

-- ---------------------------------------------------------------------
-- DELETE
-- ---------------------------------------------------------------------

-- 範例 8：刪除範例 3 新增的「待練習」紀錄
SELECT * FROM my_log WHERE chosen = '-';      -- 先確認
DELETE FROM my_log WHERE chosen = '-';

-- 範例 9：UPSERT：章節存在就更新、不存在就新增
DROP TABLE IF EXISTS my_topics;
CREATE TABLE my_topics (topic_id INTEGER PRIMARY KEY, name TEXT NOT NULL);
INSERT INTO my_topics SELECT * FROM topics;

INSERT INTO my_topics (topic_id, name) VALUES (7, '資訊安全與密碼學')
ON CONFLICT (topic_id) DO UPDATE SET name = excluded.name;    -- 7 存在 → 更新

INSERT INTO my_topics (topic_id, name) VALUES (8, '軟體工程')
ON CONFLICT (topic_id) DO UPDATE SET name = excluded.name;    -- 8 不存在 → 新增

SELECT * FROM my_topics;


-- =====================================================================
-- 練習題（都在 my_ 開頭的練習表上做）
-- =====================================================================

-- 練習 1：在 my_topics 一次新增「雲端運算」和「人工智慧」兩個章節


-- 練習 2：把 my_questions 中，網路概論（exam_id 3、5）的題目配分都加 0.5


-- 練習 3：刪除 my_log 中，2026-11-01 當天的所有紀錄（先 SELECT 確認再刪）


-- 練習 4：把 my_topics 的「人工智慧」改名為「人工智慧與機器學習」


-- 練習 5：練習結束後，刪除本課的練習表 my_questions、my_log、my_topics


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
INSERT INTO my_topics (name) VALUES ('雲端運算'), ('人工智慧');

-- 練習 2
SELECT question_id, score FROM my_questions WHERE exam_id IN (3, 5);
UPDATE my_questions SET score = score + 0.5 WHERE exam_id IN (3, 5);

-- 練習 3
SELECT * FROM my_log
WHERE answered_at >= '2026-11-01' AND answered_at < '2026-11-02';
DELETE FROM my_log
WHERE answered_at >= '2026-11-01' AND answered_at < '2026-11-02';

-- 練習 4
UPDATE my_topics SET name = '人工智慧與機器學習' WHERE name = '人工智慧';

-- 練習 5
DROP TABLE IF EXISTS my_questions;
DROP TABLE IF EXISTS my_log;
DROP TABLE IF EXISTS my_topics;

*/
