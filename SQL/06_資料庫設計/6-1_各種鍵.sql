-- =====================================================================
-- 6-1 超鍵、候選鍵、主鍵、外來鍵
-- 用 SQL 檢查「某些欄位的組合能不能唯一識別每一列」
-- 方法：比較 COUNT(*) 和 COUNT(DISTINCT 欄位組合)，相等代表沒有重複
-- =====================================================================

-- 範例 1：{question_id} 能唯一識別 questions 的每一列嗎？
SELECT COUNT(*), COUNT(DISTINCT question_id) FROM questions;   -- 30, 30 → 可以

-- 範例 2：{exam_id, question_no} 呢？
SELECT COUNT(*),
       (SELECT COUNT(*) FROM (SELECT DISTINCT exam_id, question_no FROM questions))
FROM questions;                                                -- 30, 30 → 可以

-- 範例 3：{exam_id} 呢？
SELECT COUNT(*), COUNT(DISTINCT exam_id) FROM questions;       -- 30, 5 → 不行

-- 範例 4：{question_no} 呢？
SELECT COUNT(*), COUNT(DISTINCT question_no) FROM questions;   -- 30, 7 → 不行

-- 結論：questions 的候選鍵有 {question_id} 和 {exam_id, question_no}
--      主鍵選了 {question_id}（代理鍵），{exam_id, question_no} 是替代鍵（設了 UNIQUE）
--      {question_id, content} 是超鍵，但不是候選鍵（content 是多餘的）

-- 範例 5：查看外來鍵設定
PRAGMA foreign_key_list(questions);
PRAGMA foreign_key_list(question_topics);

-- ⚠️ 注意：用「目前的資料」檢查不重複，只能證明「現在」沒重複，
--    不能證明「永遠」不會重複。候選鍵要從「業務規則」判斷，
--    例如「同一份考試不會有兩個第 1 題」，這是規則，不是剛好。


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：options 表的主鍵是 {question_id, label}。
--        用 SQL 驗證 {question_id} 和 {label} 單獨都不能當鍵


-- 練習 2：practice_log 中，{question_id, answered_at} 目前能唯一識別每一列嗎？
--        從業務規則來看，適合當候選鍵嗎？


-- 練習 3：找出 options 表中，選項內容（content）重複的情況，
--        說明為什麼 {content} 不能當鍵


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT COUNT(*), COUNT(DISTINCT question_id), COUNT(DISTINCT label) FROM options;
-- 120, 30, 4 → 兩者單獨都有重複

-- 練習 2
SELECT COUNT(*),
       (SELECT COUNT(*) FROM (SELECT DISTINCT question_id, answered_at FROM practice_log))
FROM practice_log;
-- 目前 10, 10，可以唯一識別。
-- 但從業務規則看，理論上同一分鐘內可能重複作答同一題（例如快速重做），
-- 不保證永遠唯一，所以用自動編號的 log_id 當主鍵比較安全。

-- 練習 3
SELECT content, COUNT(*) FROM options GROUP BY content HAVING COUNT(*) > 1;
-- 例如「DNS」「80」在不同題目都出現，所以 content 不能唯一識別

*/
