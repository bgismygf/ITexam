-- =====================================================================
-- 1-6 NULL 與三值邏輯
-- 提示：SQLite 用 1 表示 TRUE、0 表示 FALSE、NULL 表示 UNKNOWN
-- =====================================================================

-- 範例 1：NULL 參與運算，結果都是 NULL
SELECT NULL + 1, NULL * 0, 'A' || NULL;

-- 範例 2：NULL 參與比較，結果是 UNKNOWN（顯示為 NULL）
SELECT NULL = 1, NULL = NULL, NULL <> 1;

-- 範例 3：IS NULL 才會得到 TRUE / FALSE
SELECT NULL IS NULL, 1 IS NULL;

-- 範例 4：驗證三值邏輯的真值表
SELECT
    NULL AND 1 AS "UNKNOWN AND TRUE",
    NULL AND 0 AS "UNKNOWN AND FALSE",
    NULL OR 1  AS "UNKNOWN OR TRUE",
    NULL OR 0  AS "UNKNOWN OR FALSE",
    NOT NULL   AS "NOT UNKNOWN";

-- 範例 5：答案不是 'A' 的題目，第 29 題（NULL）不會出現
SELECT question_id, answer FROM questions
WHERE answer <> 'A';

-- 範例 6：如果也想包含 NULL，要明確寫出來
SELECT question_id, answer FROM questions
WHERE answer <> 'A' OR answer IS NULL;

-- 範例 7：COALESCE，NULL 時顯示替代文字
SELECT question_id, COALESCE(answer, '未輸入') AS 答案
FROM questions
WHERE exam_id = 5;

-- 範例 8：COALESCE 回傳第一個不是 NULL 的值
SELECT COALESCE(NULL, NULL, '第三個', '第四個');

-- 範例 9：NULLIF 避免除以 0
SELECT 10 / NULLIF(0, 0);   -- 回傳 NULL，而不是錯誤


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：預測下列結果，再執行驗證
--   (a) SELECT NULL OR 0;
--   (b) SELECT NULL AND 0;
--   (c) SELECT NOT (NULL = 1);


-- 練習 2：查出 exam_id = 5 的所有題目，答案欄位顯示成：
--        有答案就顯示答案，沒有答案就顯示「待補」


-- 練習 3：下面這句想查「答案不是 B 的題目，包含還沒輸入答案的」，但結果少了一題。
--        請修正它
--        SELECT question_id, answer FROM questions WHERE answer <> 'B';


-- 練習 4（思考題）：
--        有人寫了 WHERE answer = NULL OR answer = 'A'，會查出什麼？為什麼？


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT NULL OR 0;           -- (a) NULL（UNKNOWN）
SELECT NULL AND 0;          -- (b) 0（FALSE），有 FALSE 就是 FALSE
SELECT NOT (NULL = 1);      -- (c) NULL（UNKNOWN），NOT UNKNOWN 還是 UNKNOWN

-- 練習 2
SELECT question_id, COALESCE(answer, '待補') AS answer
FROM questions WHERE exam_id = 5;

-- 練習 3
SELECT question_id, answer FROM questions
WHERE answer <> 'B' OR answer IS NULL;

-- 練習 4
-- 只會查出答案是 A 的題目。
-- answer = NULL 永遠是 UNKNOWN，所以條件等於 UNKNOWN OR (answer = 'A')：
-- 答案是 A 時 → TRUE；其他時候 → UNKNOWN 或 FALSE，都被排除。
SELECT question_id, answer FROM questions WHERE answer = NULL OR answer = 'A';

*/
