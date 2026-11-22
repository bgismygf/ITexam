-- =====================================================================
-- 6-3 ER 圖轉換成資料表
-- 情境：設計「學生選課系統」
--   實體：學生（學號、姓名、生日、地址[縣市/區]、電話[多值]）
--         課程（課號、課名、學分）
--         系所（系所代碼、系名）
--   關係：學生 N ── 1 系所（每個學生屬於一個系）
--         學生 M ── N 課程（選修，屬性：成績）
-- =====================================================================

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS my_enrollments;
DROP TABLE IF EXISTS my_student_phones;
DROP TABLE IF EXISTS my_students;
DROP TABLE IF EXISTS my_courses;
DROP TABLE IF EXISTS my_departments;

-- 規則 1：強實體 → 一張表
CREATE TABLE my_departments (
    dept_id   TEXT PRIMARY KEY,
    dept_name TEXT NOT NULL
);

CREATE TABLE my_courses (
    course_id   TEXT PRIMARY KEY,
    course_name TEXT NOT NULL,
    credits     INTEGER NOT NULL
);

-- 規則 1 + 2 + 4 + 6：
--   複合屬性「地址」拆成 city、district
--   衍生屬性「年齡」不存（由 birthday 計算）
--   學生 N ── 1 系所：外來鍵 dept_id 放在 N 那邊（學生）
CREATE TABLE my_students (
    student_id TEXT PRIMARY KEY,
    name       TEXT NOT NULL,
    birthday   TEXT,
    city       TEXT,
    district   TEXT,
    dept_id    TEXT NOT NULL REFERENCES my_departments(dept_id)
);

-- 規則 3：多值屬性「電話」→ 另外一張表
CREATE TABLE my_student_phones (
    student_id TEXT NOT NULL REFERENCES my_students(student_id),
    phone      TEXT NOT NULL,
    PRIMARY KEY (student_id, phone)
);

-- 規則 8：M : N 關係「選修」→ 新建一張表，關係的屬性（成績）也放這裡
CREATE TABLE my_enrollments (
    student_id TEXT NOT NULL REFERENCES my_students(student_id),
    course_id  TEXT NOT NULL REFERENCES my_courses(course_id),
    score      INTEGER,
    PRIMARY KEY (student_id, course_id)
);

-- 放入測試資料
INSERT INTO my_departments VALUES ('CS', '資訊工程'), ('EE', '電機工程');
INSERT INTO my_courses VALUES ('DB', '資料庫系統', 3), ('NET', '計算機網路', 3), ('OS', '作業系統', 3);
INSERT INTO my_students VALUES
    ('S001', '王小明', '2004-03-15', '高雄市', '左營區', 'CS'),
    ('S002', '李小華', '2003-11-02', '台北市', '大安區', 'EE'),
    ('S003', '陳大同', '2004-07-21', '台中市', '西屯區', 'CS');
INSERT INTO my_student_phones VALUES ('S001', '0912-111-111'), ('S001', '07-1234567'), ('S002', '0922-222-222');
INSERT INTO my_enrollments VALUES ('S001', 'DB', 88), ('S001', 'NET', 75), ('S002', 'DB', 92), ('S003', 'OS', NULL);

-- 查詢：每位學生的系名、年齡（衍生屬性用計算的）、選修課程與成績
SELECT s.name, d.dept_name,
       CAST((julianday('now') - julianday(s.birthday)) / 365.25 AS INTEGER) AS 年齡,
       c.course_name, e.score
FROM my_students s
JOIN my_departments d ON s.dept_id = d.dept_id
LEFT JOIN my_enrollments e ON s.student_id = e.student_id
LEFT JOIN my_courses c     ON e.course_id = c.course_id;

-- 查詢：每位學生的所有電話（多值屬性）
SELECT s.name, p.phone
FROM my_students s
LEFT JOIN my_student_phones p ON s.student_id = p.student_id;


-- =====================================================================
-- 練習題
-- =====================================================================
-- 情境：圖書館系統
--   實體：書籍（ISBN、書名、出版年）、作者（作者編號、姓名）、
--         會員（會員編號、姓名、email）
--   關係：書籍 M ── N 作者（一本書可以有多位作者）
--         會員 1 ── N 借閱紀錄 ── N 1 書籍（借閱有屬性：借出日、歸還日）
--   問題：
--   1. 需要幾張表？分別是什麼？
--   2. 寫出所有 CREATE TABLE（表名用 my_lib_ 開頭）
--   3. 一位會員可以重複借同一本書（不同日期），借閱紀錄的主鍵要怎麼設計？


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 1. 共 5 張表：書籍、作者、書籍-作者（M:N 關聯表）、會員、借閱紀錄
-- 3. 借閱紀錄的主鍵不能只用 (member_id, isbn)，因為同一人可以重複借同一本書。
--    做法一：(member_id, isbn, borrow_date) 當主鍵
--    做法二（實務常用）：用自動編號 loan_id 當主鍵

DROP TABLE IF EXISTS my_lib_loans;
DROP TABLE IF EXISTS my_lib_book_authors;
DROP TABLE IF EXISTS my_lib_members;
DROP TABLE IF EXISTS my_lib_authors;
DROP TABLE IF EXISTS my_lib_books;

CREATE TABLE my_lib_books (
    isbn         TEXT PRIMARY KEY,
    title        TEXT NOT NULL,
    publish_year INTEGER
);

CREATE TABLE my_lib_authors (
    author_id INTEGER PRIMARY KEY,
    name      TEXT NOT NULL
);

CREATE TABLE my_lib_book_authors (
    isbn      TEXT    NOT NULL REFERENCES my_lib_books(isbn),
    author_id INTEGER NOT NULL REFERENCES my_lib_authors(author_id),
    PRIMARY KEY (isbn, author_id)
);

CREATE TABLE my_lib_members (
    member_id INTEGER PRIMARY KEY,
    name      TEXT NOT NULL,
    email     TEXT UNIQUE
);

CREATE TABLE my_lib_loans (
    loan_id     INTEGER PRIMARY KEY,
    member_id   INTEGER NOT NULL REFERENCES my_lib_members(member_id),
    isbn        TEXT    NOT NULL REFERENCES my_lib_books(isbn),
    borrow_date TEXT    NOT NULL,
    return_date TEXT
);

-- 清除練習表
DROP TABLE my_lib_loans;
DROP TABLE my_lib_book_authors;
DROP TABLE my_lib_members;
DROP TABLE my_lib_authors;
DROP TABLE my_lib_books;

*/

-- 清除本課範例的練習表（要保留可以不執行）
DROP TABLE IF EXISTS my_enrollments;
DROP TABLE IF EXISTS my_student_phones;
DROP TABLE IF EXISTS my_students;
DROP TABLE IF EXISTS my_courses;
DROP TABLE IF EXISTS my_departments;
