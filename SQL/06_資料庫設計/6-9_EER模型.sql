-- =====================================================================
-- 6-9 EER 模型：父型態與子型態轉換成資料表
-- 情境：115 年調查局考題的公司人員分類
--   人員（父型態）：完全特殊化、重疊 → 員工、客戶
--   員工（父型態）：部分特殊化、互斥 → 行政人員、技術人員、顧問
-- 轉換方法：父、子各一張表（方法 1）
-- 所有練習表都以 my_ 開頭，不會動到題庫
-- =====================================================================

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS my_consultants;
DROP TABLE IF EXISTS my_technicians;
DROP TABLE IF EXISTS my_admins;
DROP TABLE IF EXISTS my_customers;
DROP TABLE IF EXISTS my_employees;
DROP TABLE IF EXISTS my_persons;

-- 父型態：人員
-- 重疊 → 鑑別子用兩個旗標欄位；完全 → 至少一個是 'Y'（用 CHECK 檢查）
CREATE TABLE my_persons (
    ssn         TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    is_employee TEXT NOT NULL CHECK (is_employee IN ('Y', 'N')),
    is_customer TEXT NOT NULL CHECK (is_customer IN ('Y', 'N')),
    CHECK (is_employee = 'Y' OR is_customer = 'Y')      -- 完全特殊化
);

-- 子型態：員工（同時也是下一層的父型態）
-- 主鍵 = 父型態的主鍵，同時是外來鍵
-- 互斥 → 鑑別子用一個欄位；部分 → 可以是 NULL（三種都不是）
CREATE TABLE my_employees (
    ssn   TEXT PRIMARY KEY REFERENCES my_persons(ssn),
    dept  TEXT NOT NULL,
    etype TEXT CHECK (etype IN ('A', 'T', 'C'))           -- A 行政、T 技術、C 顧問
);

-- 子型態：客戶
CREATE TABLE my_customers (
    ssn          TEXT PRIMARY KEY REFERENCES my_persons(ssn),
    credit_limit INTEGER NOT NULL
);

-- 員工的子型態：各自只放特有屬性
CREATE TABLE my_admins (
    ssn    TEXT PRIMARY KEY REFERENCES my_employees(ssn),
    office TEXT                                           -- 辦公室
);
CREATE TABLE my_technicians (
    ssn   TEXT PRIMARY KEY REFERENCES my_employees(ssn),
    skill TEXT                                            -- 專長
);
CREATE TABLE my_consultants (
    ssn       TEXT PRIMARY KEY REFERENCES my_employees(ssn),
    day_rate  INTEGER                                     -- 日薪
);

-- 資料
INSERT INTO my_persons VALUES
    ('P01', '王小明', 'Y', 'N'),     -- 只是員工
    ('P02', '李小華', 'Y', 'Y'),     -- 既是員工也是客戶（重疊）
    ('P03', '陳美玲', 'N', 'Y'),     -- 只是客戶
    ('P04', '張大同', 'Y', 'N'),
    ('P05', '林志明', 'Y', 'N');
INSERT INTO my_employees VALUES
    ('P01', '總務部', 'A'),
    ('P02', '研發部', 'T'),
    ('P04', '研發部', 'C'),
    ('P05', '業務部', NULL);         -- 部分特殊化：三種都不是
INSERT INTO my_customers VALUES ('P02', 50000), ('P03', 200000);
INSERT INTO my_admins      VALUES ('P01', 'A棟3樓');
INSERT INTO my_technicians VALUES ('P02', '資料庫');
INSERT INTO my_consultants VALUES ('P04', 8000);

-- 範例 1：違反「完全特殊化」：既不是員工也不是客戶
INSERT INTO my_persons VALUES ('P99', '路人甲', 'N', 'N');   -- 預期錯誤：CHECK constraint failed

-- 範例 2：違反「互斥」：鑑別子只有一個欄位，一個員工只能填一種類別
UPDATE my_employees SET etype = 'AT' WHERE ssn = 'P01';     -- 預期錯誤：CHECK constraint failed

-- 範例 3（115 年考題第四小題）：列出每位員工的身分證號、姓名、部門、職務類別
SELECT p.ssn, p.name, e.dept,
       CASE e.etype
           WHEN 'A' THEN '行政人員'
           WHEN 'T' THEN '技術人員'
           WHEN 'C' THEN '顧問'
           ELSE '（無）'
       END AS 職務類別
FROM my_persons p
JOIN my_employees e ON e.ssn = p.ssn
ORDER BY p.ssn;

-- 範例 4：屬性繼承：技術人員的完整資料 = 人員 + 員工 + 技術人員三張表 JOIN
SELECT p.ssn, p.name, e.dept, t.skill
FROM my_technicians t
JOIN my_employees e ON e.ssn = t.ssn
JOIN my_persons p   ON p.ssn = t.ssn;

-- 範例 5：重疊：既是員工又是客戶的人
SELECT ssn, name FROM my_persons
WHERE is_employee = 'Y' AND is_customer = 'Y';


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：列出所有客戶的姓名和信用額度，並標示他是不是員工


-- 練習 2：鑑別子和子型態表要一致。找出「etype = 'T'，但 my_technicians 裡沒有資料」的員工
--        （目前資料一致，結果應為空。可以自己新增一筆不一致的資料試試看）


-- 練習 3（紙筆）：學校的「人員」分成「學生」「教職員」，
--        每個人一定是其中至少一種，也可能兩者都是（例如在職專班的教職員）。
--        (a) 這是哪一種完整性限制、哪一種互斥性限制？
--        (b) 用「父、子各一張表」寫出資料表綱要，標出 PK、FK 和鑑別子
--        (c) 能不能用「只建子型態的表」？為什麼？


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT p.name, c.credit_limit,
       CASE p.is_employee WHEN 'Y' THEN '是' ELSE '否' END AS 是否為員工
FROM my_customers c
JOIN my_persons p ON p.ssn = c.ssn;
-- 結果：李小華 50000 是、陳美玲 200000 否

-- 練習 2
SELECT e.ssn
FROM my_employees e
WHERE e.etype = 'T'
  AND NOT EXISTS (SELECT 1 FROM my_technicians t WHERE t.ssn = e.ssn);

-- 練習 3
-- (a) 完全特殊化（每人一定至少是一種）、重疊（可以兩者都是）
-- (b) 人員(人員編號 PK, 姓名, 是否學生, 是否教職員)
--       ← 鑑別子是兩個是非欄位，且至少一個為「是」
--     學生(人員編號 PK/FK→人員, 學號, 系所)
--     教職員(人員編號 PK/FK→人員, 職稱, 薪資)
-- (c) 不建議。只建子型態表時，兩者都是的人，姓名等共同資料會在兩張表各存一次，
--     造成重複和更新異常（6-4 課）。只建子型態表只適合「完全＋互斥」。

*/
