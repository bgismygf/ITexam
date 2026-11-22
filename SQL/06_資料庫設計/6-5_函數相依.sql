-- =====================================================================
-- 6-5 函數相依：用 SQL 檢查資料是否違反某個 FD
-- 方法：X → Y 成立，代表「每個 X 值只對應一個 Y 值」
--       所以 GROUP BY X，檢查 COUNT(DISTINCT Y) 是否都是 1
-- =====================================================================

-- 範例 1：檢查 questions 中 question_id → exam_id 是否成立
SELECT question_id, COUNT(DISTINCT exam_id)
FROM questions
GROUP BY question_id
HAVING COUNT(DISTINCT exam_id) > 1;     -- 沒有結果 = 沒有違反

-- 範例 2：檢查 exam_id → question_id 是否成立（應該不成立）
SELECT exam_id, COUNT(DISTINCT question_id) AS 對應的題目數
FROM questions
GROUP BY exam_id
HAVING COUNT(DISTINCT question_id) > 1; -- 有結果 = FD 不成立

-- 範例 3：檢查 {exam_id, question_no} → content
SELECT exam_id, question_no, COUNT(DISTINCT content)
FROM questions
GROUP BY exam_id, question_no
HAVING COUNT(DISTINCT content) > 1;     -- 沒有結果 = 沒有違反

-- 範例 4：題目 + 考試 JOIN 起來的大表中，
--         question_id → year 成立（透過 exam_id 的遞移相依）
SELECT q.question_id, COUNT(DISTINCT e.year)
FROM questions q JOIN exams e ON q.exam_id = e.exam_id
GROUP BY q.question_id
HAVING COUNT(DISTINCT e.year) > 1;

-- ⚠️ 提醒：資料「沒有違反」不代表 FD 成立。
--    FD 是業務規則，資料只能用來「推翻」FD，不能「證明」FD。
--    例如：目前每個年度只有一份計算機原理，year + subject → exam_id 看起來成立，
--    但如果未來同一年舉辦兩次考試，就不成立了。
SELECT year, subject, COUNT(DISTINCT exam_id)
FROM exams
GROUP BY year, subject
HAVING COUNT(DISTINCT exam_id) > 1;


-- =====================================================================
-- 練習題（紙筆計算）
-- =====================================================================

-- 練習 1：R(A, B, C, D, E)，FD = { A → BC, CD → E, B → D, E → A }
--        (a) 求 {A}⁺
--        (b) 求 {B, C}⁺
--        (c) 找出所有候選鍵

-- 練習 2：R(員工編號, 姓名, 部門編號, 部門名稱, 專案編號, 工時)
--        業務規則：員工屬於一個部門；一個員工可以參與多個專案；
--                  每個員工在每個專案有一個工時
--        (a) 寫出所有 FD
--        (b) 找出候選鍵
--        (c) 找出部分相依和遞移相依

-- 練習 3：用 SQL 檢查 options 表中，{question_id, label} → content 是否有被違反


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
-- (a) {A}⁺：A → BC 加入 B、C → {A,B,C}；B → D 加入 D → {A,B,C,D}；
--          CD → E 加入 E → {A,B,C,D,E}。{A}⁺ = 全部屬性 → A 是候選鍵
-- (b) {B,C}⁺：B → D → {B,C,D}；CD → E → {B,C,D,E}；E → A → {A,B,C,D,E} → 超鍵
--          檢查最小性：{B}⁺ = {B,D}，{C}⁺ = {C}，都不是超鍵 → {B,C} 是候選鍵
-- (c) 候選鍵：{A}、{E}、{B,C}、{C,D}
--     {E}⁺：E → A → 再得到全部 → 候選鍵
--     {C,D}⁺：CD → E → E → A → 全部 → 候選鍵（{C}⁺={C}、{D}⁺={D}，所以是最小）

-- 練習 2
-- (a) 員工編號 → 姓名, 部門編號
--     部門編號 → 部門名稱
--     {員工編號, 專案編號} → 工時
-- (b) 候選鍵：{員工編號, 專案編號}
-- (c) 部分相依：{員工編號, 專案編號} → 姓名、部門編號（只需要員工編號）
--     遞移相依：員工編號 → 部門編號 → 部門名稱

-- 練習 3
SELECT question_id, label, COUNT(DISTINCT content)
FROM options
GROUP BY question_id, label
HAVING COUNT(DISTINCT content) > 1;   -- 沒有結果（而且這是主鍵，本來就不可能違反）

*/
