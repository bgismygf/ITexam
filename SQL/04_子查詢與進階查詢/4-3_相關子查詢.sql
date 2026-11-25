-- =====================================================================
-- 4-3 相關子查詢
-- =====================================================================

-- 範例 1：配分高於「該份考試」平均的題目
SELECT q.exam_id, q.question_id, q.score
FROM questions q
WHERE q.score > (SELECT AVG(score) FROM questions WHERE exam_id = q.exam_id);

-- 範例 2：每份考試中配分最高的題目（同分會全部列出）
SELECT q.exam_id, q.question_id, q.score
FROM questions q
WHERE q.score = (SELECT MAX(score) FROM questions WHERE exam_id = q.exam_id)
ORDER BY q.exam_id, q.question_id;

-- 範例 3：每題最近一次的作答紀錄
SELECT * FROM practice_log p
WHERE p.answered_at = (SELECT MAX(answered_at) FROM practice_log
                       WHERE question_id = p.question_id);

-- 範例 4：放在 SELECT 中的相關子查詢：每份考試的題數
SELECT e.exam_id, e.year, e.subject,
       (SELECT COUNT(*) FROM questions q WHERE q.exam_id = e.exam_id) AS 實際題數
FROM exams e;

-- 範例 5：相關子查詢改寫成 JOIN + GROUP BY（結果與範例 4 相同）
SELECT e.exam_id, e.year, e.subject, COUNT(q.question_id) AS 實際題數
FROM exams e
LEFT JOIN questions q ON q.exam_id = e.exam_id
GROUP BY e.exam_id, e.year, e.subject;

-- ---------------------------------------------------------------------
-- 關聯除法：找出「修了 Jessica 老師所教的所有課程」的學生
-- （115 年國營統計資訊類改編；用 WITH 臨時造資料，不會動到題庫）
--   Jessica 教 C1、C2；Tom 教 C3
--   Amy 修 C1 C2 C3、Bob 修 C1 C3、Cindy 修 C1 C2、Julie 修 C3
--   正確答案：Amy、Cindy
-- ---------------------------------------------------------------------

-- 範例 6：雙重 NOT EXISTS
WITH
Students(Sid, Sname, Tname) AS (
    VALUES ('S1', 'Amy', 'Jessica'), ('S2', 'Bob', 'Tom'),
           ('S3', 'Cindy', 'Jessica'), ('S4', 'Julie', 'Tom')
),
Courses(Cno, Ctitle, Tname) AS (
    VALUES ('C1', '資料庫', 'Jessica'), ('C2', '作業系統', 'Jessica'), ('C3', '網路', 'Tom')
),
Takes(Sid, Cno, Score) AS (
    VALUES ('S1', 'C1', 90), ('S1', 'C2', 85), ('S1', 'C3', 70),
           ('S2', 'C1', 60), ('S2', 'C3', 75),
           ('S3', 'C1', 88), ('S3', 'C2', 92),
           ('S4', 'C3', 80)
)
SELECT s.Sid, s.Sname
FROM Students s
WHERE NOT EXISTS (
    SELECT * FROM Courses c
    WHERE c.Tname = 'Jessica'
      AND NOT EXISTS (
          SELECT * FROM Takes t
          WHERE t.Sid = s.Sid AND t.Cno = c.Cno
      )
);   -- S1 Amy、S3 Cindy

-- 範例 7：GROUP BY + HAVING COUNT（資料同上）
WITH
Students(Sid, Sname, Tname) AS (
    VALUES ('S1', 'Amy', 'Jessica'), ('S2', 'Bob', 'Tom'),
           ('S3', 'Cindy', 'Jessica'), ('S4', 'Julie', 'Tom')
),
Courses(Cno, Ctitle, Tname) AS (
    VALUES ('C1', '資料庫', 'Jessica'), ('C2', '作業系統', 'Jessica'), ('C3', '網路', 'Tom')
),
Takes(Sid, Cno, Score) AS (
    VALUES ('S1', 'C1', 90), ('S1', 'C2', 85), ('S1', 'C3', 70),
           ('S2', 'C1', 60), ('S2', 'C3', 75),
           ('S3', 'C1', 88), ('S3', 'C2', 92),
           ('S4', 'C3', 80)
)
SELECT s.Sid, s.Sname
FROM Students s
JOIN Takes t   ON t.Sid = s.Sid
JOIN Courses c ON c.Cno = t.Cno
WHERE c.Tname = 'Jessica'
GROUP BY s.Sid, s.Sname
HAVING COUNT(DISTINCT t.Cno) = (SELECT COUNT(*) FROM Courses WHERE Tname = 'Jessica');
-- S1 Amy、S3 Cindy

-- 範例 8：⚠️ 陷阱：忘了 WHERE c.Tname = 'Jessica'（資料同上）
WITH
Students(Sid, Sname, Tname) AS (
    VALUES ('S1', 'Amy', 'Jessica'), ('S2', 'Bob', 'Tom'),
           ('S3', 'Cindy', 'Jessica'), ('S4', 'Julie', 'Tom')
),
Courses(Cno, Ctitle, Tname) AS (
    VALUES ('C1', '資料庫', 'Jessica'), ('C2', '作業系統', 'Jessica'), ('C3', '網路', 'Tom')
),
Takes(Sid, Cno, Score) AS (
    VALUES ('S1', 'C1', 90), ('S1', 'C2', 85), ('S1', 'C3', 70),
           ('S2', 'C1', 60), ('S2', 'C3', 75),
           ('S3', 'C1', 88), ('S3', 'C2', 92),
           ('S4', 'C3', 80)
)
SELECT s.Sid, s.Sname
FROM Students s
JOIN Takes t ON t.Sid = s.Sid
GROUP BY s.Sid, s.Sname
HAVING COUNT(DISTINCT t.Cno) = (SELECT COUNT(*) FROM Courses WHERE Tname = 'Jessica');
-- 錯誤結果：S2 Bob、S3 Cindy
-- Bob 只修了一門 Jessica 的課，卻因為「總共修 2 門」被選出來；
-- Amy 修滿了，卻因為「總共修 3 門」被漏掉


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：找出每份考試的最後一題（題號最大的那題），顯示 exam_id、題號、內容


-- 練習 2：列出每個章節的名稱，以及該章節的作答次數（用 SELECT 中的相關子查詢）


-- 練習 3（本單元練習）：找出「最近一次作答是答錯」的題目
--        也就是：答錯過，而且後來還沒有答對的題目
--        提示：沿用範例 3，再加上 is_correct = 0


-- 練習 4：檢查資料：exams.question_count 和實際題數不一致的考試
--        （目前應該都一致，結果為空）


-- 練習 5（113 年國營「鐵粉」題改編，先在紙上寫）：
--        買過「達文西」所有書的讀者，稱為達文西的「鐵粉」，請列出鐵粉的姓名。
--        (a) 用雙重 NOT EXISTS 寫
--        (b) 用 GROUP BY + HAVING COUNT 寫
--        注意：同一位讀者可能重複買同一本書（Buy 的主鍵包含購買時間）
--        資料如下，把 WITH 這段放在你的查詢前面：
--
-- WITH
-- Member(mId, name) AS (VALUES ('M1', '小明'), ('M2', '小華'), ('M3', '小美')),
-- Author(pNo, name) AS (VALUES ('P1', '達文西'), ('P2', '達文西'), ('P3', '村上春樹')),
-- Buy(mId, pNo, BuyTime) AS (
--     VALUES ('M1', 'P1', '2024-01-01'), ('M1', 'P1', '2024-02-01'), ('M1', 'P2', '2024-03-01'),
--            ('M2', 'P1', '2024-01-05'), ('M2', 'P3', '2024-01-06'),
--            ('M3', 'P1', '2024-04-01'), ('M3', 'P2', '2024-04-01'), ('M3', 'P3', '2024-04-02')
-- )


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT q.exam_id, q.question_no, q.content
FROM questions q
WHERE q.question_no = (SELECT MAX(question_no) FROM questions WHERE exam_id = q.exam_id);

-- 練習 2
SELECT t.name,
       (SELECT COUNT(*)
        FROM practice_log p
        JOIN question_topics qt ON p.question_id = qt.question_id
        WHERE qt.topic_id = t.topic_id) AS 作答次數
FROM topics t;

-- 練習 3
SELECT p.question_id, p.answered_at, p.chosen
FROM practice_log p
WHERE p.is_correct = 0
  AND p.answered_at = (SELECT MAX(answered_at) FROM practice_log
                       WHERE question_id = p.question_id);
-- 結果：第 2、13、16、22 題（第 8 題後來答對了，所以不在裡面）

-- 練習 4
SELECT e.* FROM exams e
WHERE e.question_count <> (SELECT COUNT(*) FROM questions q WHERE q.exam_id = e.exam_id);

-- 練習 5
WITH
Member(mId, name) AS (VALUES ('M1', '小明'), ('M2', '小華'), ('M3', '小美')),
Author(pNo, name) AS (VALUES ('P1', '達文西'), ('P2', '達文西'), ('P3', '村上春樹')),
Buy(mId, pNo, BuyTime) AS (
    VALUES ('M1', 'P1', '2024-01-01'), ('M1', 'P1', '2024-02-01'), ('M1', 'P2', '2024-03-01'),
           ('M2', 'P1', '2024-01-05'), ('M2', 'P3', '2024-01-06'),
           ('M3', 'P1', '2024-04-01'), ('M3', 'P2', '2024-04-01'), ('M3', 'P3', '2024-04-02')
)
-- (a) 雙重 NOT EXISTS：不存在任何一本達文西的書，是他沒買過的
SELECT m.name
FROM Member m
WHERE NOT EXISTS (
    SELECT * FROM Author a
    WHERE a.name = '達文西'
      AND NOT EXISTS (
          SELECT * FROM Buy b
          WHERE b.mId = m.mId AND b.pNo = a.pNo
      )
);
-- 結果：小明、小美

-- (b) GROUP BY + HAVING COUNT（WITH 同上）
-- SELECT m.name
-- FROM Member m
-- JOIN Buy b    ON b.mId = m.mId
-- JOIN Author a ON a.pNo = b.pNo
-- WHERE a.name = '達文西'
-- GROUP BY m.mId, m.name
-- HAVING COUNT(DISTINCT b.pNo) = (SELECT COUNT(*) FROM Author WHERE name = '達文西');
-- 結果：小明、小美
-- ⚠️ 如果寫成 COUNT(b.pNo)（沒有 DISTINCT），小明買了 P1 兩次，會算成 3 本 ≠ 2，被漏掉

*/
