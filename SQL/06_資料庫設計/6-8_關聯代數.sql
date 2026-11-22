-- =====================================================================
-- 6-8 關聯代數：每個運算對應的 SQL
-- =====================================================================

-- σ 選擇：σ_year=113(exams)
SELECT * FROM exams WHERE year = 113;

-- π 投影：π_subject(exams)（關聯代數會去除重複，所以要加 DISTINCT）
SELECT DISTINCT subject FROM exams;

-- 組合：π_subject(σ_year=113(exams))
SELECT DISTINCT subject FROM exams WHERE year = 113;

-- × 笛卡兒積：exams × topics
SELECT * FROM exams CROSS JOIN topics;

-- ⋈ 等值合併：questions ⋈_questions.exam_id=exams.exam_id exams
SELECT * FROM questions q JOIN exams e ON q.exam_id = e.exam_id;

-- 合併 = 笛卡兒積 + 選擇：σ_questions.exam_id=exams.exam_id(questions × exams)
SELECT * FROM questions q CROSS JOIN exams e WHERE q.exam_id = e.exam_id;

-- ∪ ∩ − 集合運算（3-6 課）
SELECT question_id FROM practice_log
INTERSECT
SELECT question_id FROM question_topics WHERE topic_id = 1;

-- ∩ 可以用 − 表示：R ∩ S = R − (R − S)
SELECT question_id FROM practice_log
EXCEPT
SELECT * FROM (
    SELECT question_id FROM practice_log
    EXCEPT
    SELECT question_id FROM question_topics WHERE topic_id = 1
);

-- ---------------------------------------------------------------------
-- ÷ 除法：找出修了「所有必修課」的學生
-- ---------------------------------------------------------------------

-- 方法 1：雙重 NOT EXISTS
WITH
enroll(student, course) AS (
    VALUES ('S1', 'DB'), ('S1', 'OS'), ('S1', 'NET'),
           ('S2', 'DB'), ('S2', 'NET'),
           ('S3', 'DB'), ('S3', 'OS')
),
required(course) AS (VALUES ('DB'), ('OS'))
SELECT DISTINCT r1.student
FROM enroll r1
WHERE NOT EXISTS (
    SELECT * FROM required s
    WHERE NOT EXISTS (
        SELECT * FROM enroll r2
        WHERE r2.student = r1.student AND r2.course = s.course
    )
);   -- S1, S3

-- 方法 2：GROUP BY + HAVING COUNT
WITH
enroll(student, course) AS (
    VALUES ('S1', 'DB'), ('S1', 'OS'), ('S1', 'NET'),
           ('S2', 'DB'), ('S2', 'NET'),
           ('S3', 'DB'), ('S3', 'OS')
),
required(course) AS (VALUES ('DB'), ('OS'))
SELECT student
FROM enroll
WHERE course IN (SELECT course FROM required)
GROUP BY student
HAVING COUNT(DISTINCT course) = (SELECT COUNT(*) FROM required);   -- S1, S3


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：把下列關聯代數翻譯成 SQL，並執行
--        (a) π_content(σ_score>2(questions))
--        (b) π_year,subject(σ_wrong_penalty=0(exams))
--        (c) π_name(topics ⋈ question_topics ⋈ σ_exam_id=3(questions))
--            （⋈ 為自然合併）


-- 練習 2：把下列 SQL 寫成關聯代數（紙筆）
--        SELECT DISTINCT e.year
--        FROM exams e JOIN questions q ON e.exam_id = q.exam_id
--        WHERE q.answer = 'D';


-- 練習 3（除法）：找出「題目涵蓋了『網路』和『資訊安全』兩個章節」的考試
--        也就是：考試 ÷ {網路, 資訊安全}
--        提示：先做出 (exam_id, topic_name) 的配對


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
-- (a)
SELECT DISTINCT content FROM questions WHERE score > 2;
-- (b)
SELECT DISTINCT year, subject FROM exams WHERE wrong_penalty = 0;
-- (c)
SELECT DISTINCT t.name
FROM topics t
JOIN question_topics qt ON t.topic_id = qt.topic_id
JOIN questions q        ON qt.question_id = q.question_id
WHERE q.exam_id = 3;

-- 練習 2
-- π_year(σ_answer='D'(exams ⋈_exams.exam_id=questions.exam_id questions))

-- 練習 3
WITH exam_topic AS (
    SELECT DISTINCT q.exam_id, t.name
    FROM questions q
    JOIN question_topics qt ON q.question_id = qt.question_id
    JOIN topics t           ON qt.topic_id = t.topic_id
)
SELECT exam_id
FROM exam_topic
WHERE name IN ('網路', '資訊安全')
GROUP BY exam_id
HAVING COUNT(DISTINCT name) = 2;
-- 結果：exam 3（第 14～18 題是網路，第 19 題是資訊安全）、exam 5

*/
