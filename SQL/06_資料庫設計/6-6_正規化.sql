-- =====================================================================
-- 6-6 正規化：把一張「大雜燴」考題表逐步正規化（本單元練習）
-- =====================================================================

-- ---------------------------------------------------------------------
-- 未正規化：假設有人用 Excel 整理考題，直接匯入成一張表
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS my_flat;

CREATE TABLE my_flat (
    question_id   INTEGER,
    year          INTEGER,
    subject       TEXT,
    wrong_penalty INTEGER,
    question_no   INTEGER,
    content       TEXT,
    answer        TEXT,
    topics        TEXT       -- 多個章節用逗號分隔 ← 違反 1NF
);

-- 用現有題庫產生這張大雜燴表（group_concat 把多個值串成一個字串）
INSERT INTO my_flat
SELECT q.question_id, e.year, e.subject, e.wrong_penalty, q.question_no, q.content, q.answer,
       (SELECT group_concat(t.name, ',')
        FROM question_topics qt JOIN topics t ON qt.topic_id = t.topic_id
        WHERE qt.question_id = q.question_id)
FROM questions q
JOIN exams e ON q.exam_id = e.exam_id;

SELECT * FROM my_flat;

-- 違反 1NF 的問題：想找「資訊安全」的題目，只能用 LIKE，
-- 如果有個章節叫「資訊安全管理」，也會被誤抓
SELECT question_id, topics FROM my_flat WHERE topics LIKE '%資訊安全%';

-- ---------------------------------------------------------------------
-- 1NF：把多值的 topics 拆成多列
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS my_1nf;

CREATE TABLE my_1nf AS
SELECT q.question_id, e.year, e.subject, e.wrong_penalty, q.question_no,
       q.content, q.answer, t.name AS topic
FROM questions q
JOIN exams e            ON q.exam_id = e.exam_id
JOIN question_topics qt ON q.question_id = qt.question_id
JOIN topics t           ON qt.topic_id = t.topic_id;

SELECT * FROM my_1nf ORDER BY question_id;
-- 主鍵：{question_id, topic}
-- FD：question_id → year, subject, wrong_penalty, question_no, content, answer
--     {year, subject} → wrong_penalty（假設每年每科只考一次）
-- 問題：第 19、26 題的內容重複存了兩次（因為有兩個章節）

-- ---------------------------------------------------------------------
-- 2NF：消除部分相依
-- 除了 topic，其他屬性都只依賴 question_id（主鍵的一部分）→ 拆出去
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS my_2nf_questions;
DROP TABLE IF EXISTS my_2nf_question_topics;

CREATE TABLE my_2nf_questions AS
SELECT DISTINCT question_id, year, subject, wrong_penalty, question_no, content, answer
FROM my_1nf;

CREATE TABLE my_2nf_question_topics AS
SELECT DISTINCT question_id, topic
FROM my_1nf;

SELECT * FROM my_2nf_questions;
-- 主鍵：{question_id}（單一屬性 → 一定符合 2NF）
-- 但 question_id → {year, subject} → wrong_penalty 是遞移相依
-- 問題：「110 年計算機原理倒扣」重複存了 6 次

-- ---------------------------------------------------------------------
-- 3NF：消除遞移相依
-- 把 {year, subject} → wrong_penalty 拆出去，成為「考試」表
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS my_3nf_exams;
DROP TABLE IF EXISTS my_3nf_questions;

CREATE TABLE my_3nf_exams AS
SELECT DISTINCT year, subject, wrong_penalty
FROM my_2nf_questions;

CREATE TABLE my_3nf_questions AS
SELECT question_id, year, subject, question_no, content, answer
FROM my_2nf_questions;

SELECT * FROM my_3nf_exams;
-- 實務上會再替考試加一個代理鍵 exam_id，questions 改用 exam_id 參照
-- topic 也會拆成 topics 表 + topic_id，避免章節名稱重複存放
-- → 最後就得到 data/建立題庫.sql 裡的設計！

-- ---------------------------------------------------------------------
-- 驗證「無損合併」：把 3NF 的表 JOIN 回來，應該跟 1NF 的資料完全一樣
-- ---------------------------------------------------------------------
SELECT COUNT(*) FROM (
    SELECT q.question_id, e.year, e.subject, e.wrong_penalty, q.question_no,
           q.content, q.answer, qt.topic
    FROM my_3nf_questions q
    JOIN my_3nf_exams e ON q.year = e.year AND q.subject = e.subject
    JOIN my_2nf_question_topics qt ON q.question_id = qt.question_id
    EXCEPT
    SELECT * FROM my_1nf
);   -- 0 = 沒有多出來的資料

SELECT COUNT(*) FROM (
    SELECT * FROM my_1nf
    EXCEPT
    SELECT q.question_id, e.year, e.subject, e.wrong_penalty, q.question_no,
           q.content, q.answer, qt.topic
    FROM my_3nf_questions q
    JOIN my_3nf_exams e ON q.year = e.year AND q.subject = e.subject
    JOIN my_2nf_question_topics qt ON q.question_id = qt.question_id
);   -- 0 = 沒有少掉的資料


-- =====================================================================
-- 練習題（紙筆）
-- =====================================================================

-- 練習 1：訂單(訂單編號, 訂購日期, 客戶編號, 客戶姓名, 客戶電話, 商品編號, 商品名稱, 單價, 數量)
--        FD：訂單編號 → 訂購日期, 客戶編號
--            客戶編號 → 客戶姓名, 客戶電話
--            商品編號 → 商品名稱, 單價
--            {訂單編號, 商品編號} → 數量
--        (a) 候選鍵是什麼？
--        (b) 目前符合第幾正規化？
--        (c) 分解到 3NF


-- 練習 2：R(A, B, C, D, E)，FD：A → B、B → C、A → D、D → E。候選鍵 {A}。
--        R 符合第幾正規化？請分解到 3NF。


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
-- (a) {訂單編號, 商品編號}
-- (b) 1NF（訂購日期、客戶編號等只依賴訂單編號，是部分相依）
-- (c) 2NF：
--       訂單(訂單編號, 訂購日期, 客戶編號, 客戶姓名, 客戶電話)
--       商品(商品編號, 商品名稱, 單價)
--       訂單明細(訂單編號, 商品編號, 數量)
--     3NF：訂單表中，訂單編號 → 客戶編號 → 客戶姓名 是遞移相依，再拆：
--       訂單(訂單編號, 訂購日期, 客戶編號)
--       客戶(客戶編號, 客戶姓名, 客戶電話)
--       商品(商品編號, 商品名稱, 單價)
--       訂單明細(訂單編號, 商品編號, 數量)
--     💼 這就是電商系統最經典的資料表設計

-- 練習 2
-- 候選鍵 {A} 是單一屬性 → 符合 2NF
-- A → B → C、A → D → E 是遞移相依 → 不符合 3NF
-- 分解：R1(A, B, D)、R2(B, C)、R3(D, E)

*/

-- 清除練習表
DROP TABLE IF EXISTS my_flat;
DROP TABLE IF EXISTS my_1nf;
DROP TABLE IF EXISTS my_2nf_questions;
DROP TABLE IF EXISTS my_2nf_question_topics;
DROP TABLE IF EXISTS my_3nf_exams;
DROP TABLE IF EXISTS my_3nf_questions;
