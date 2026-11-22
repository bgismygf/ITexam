-- =====================================================================
-- 6-4 資料異常：實際操作看看
-- =====================================================================

DROP TABLE IF EXISTS my_enrollment_bad;

CREATE TABLE my_enrollment_bad (
    student_id TEXT,
    name       TEXT,
    dept       TEXT,
    dept_head  TEXT,
    course_id  TEXT,
    course     TEXT,
    score      INTEGER,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO my_enrollment_bad VALUES
    ('S001', '王小明', '資工', '張教授', 'DB',  '資料庫',   88),
    ('S001', '王小明', '資工', '張教授', 'NET', '網路',     75),
    ('S002', '李小華', '電機', '林教授', 'DB',  '資料庫',   92),
    ('S003', '陳大同', '資工', '張教授', 'OS',  '作業系統', 80);

SELECT * FROM my_enrollment_bad;

-- ---------------------------------------------------------------------
-- 1. 新增異常：想新增課程「AI」，但沒有學生選
--    SQLite 的歷史包袱允許非 INTEGER 主鍵為 NULL，這裡用 NOT NULL 版本示範
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS my_enrollment_bad2;
CREATE TABLE my_enrollment_bad2 (
    student_id TEXT NOT NULL, course_id TEXT NOT NULL, course TEXT,
    PRIMARY KEY (student_id, course_id)
);
-- 預期錯誤
INSERT INTO my_enrollment_bad2 (student_id, course_id, course) VALUES (NULL, 'AI', '人工智慧');

-- ---------------------------------------------------------------------
-- 2. 刪除異常：李小華退選資料庫
-- ---------------------------------------------------------------------
DELETE FROM my_enrollment_bad WHERE student_id = 'S002' AND course_id = 'DB';

-- 電機系的系主任是誰？資料消失了
SELECT DISTINCT dept, dept_head FROM my_enrollment_bad;

-- ---------------------------------------------------------------------
-- 3. 修改異常：資工系換系主任，但只改了一筆
-- ---------------------------------------------------------------------
UPDATE my_enrollment_bad
SET dept_head = '黃教授'
WHERE student_id = 'S001' AND course_id = 'DB';

-- 資工系現在有兩個系主任？資料不一致
SELECT DISTINCT dept, dept_head FROM my_enrollment_bad;

-- 找出這種不一致的 SQL（工作上做資料檢查很常用）
SELECT dept, COUNT(DISTINCT dept_head) AS 系主任人數
FROM my_enrollment_bad
GROUP BY dept
HAVING COUNT(DISTINCT dept_head) > 1;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：想新增一位剛入學、還沒選課的學生 S004 張小美（資工系），
--        在 my_enrollment_bad 的設計下會遇到什麼問題？


-- 練習 2：「網路」課要改名為「計算機網路」，需要改幾筆？
--        如果這門課有 500 個學生選，會怎樣？


-- 練習 3（思考題）：要怎麼拆表，才能避免上面三種異常？
--        先自己想想看，6-6 課會正式教


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
-- 主鍵是 (student_id, course_id)，還沒選課 → course_id 沒有值 → 新增異常
-- （在 SQLite 會因為歷史包袱而成功新增，但其他資料庫會拒絕；就算成功也是一筆不合理的資料）

-- 練習 2
-- 目前只有 1 筆。有 500 個學生選就要改 500 筆，漏改任何一筆就會不一致（修改異常）

-- 練習 3
-- 拆成四張表：
--   學生(學號, 姓名, 系所)
--   系所(系所, 系主任)
--   課程(課號, 課名)
--   選課(學號, 課號, 成績)

*/

DROP TABLE IF EXISTS my_enrollment_bad;
DROP TABLE IF EXISTS my_enrollment_bad2;
