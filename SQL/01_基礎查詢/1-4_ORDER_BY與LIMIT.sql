-- =====================================================================
-- 1-4 ORDER BY 與 LIMIT
-- =====================================================================

-- 範例 1：依年度遞增排序（ASC 可省略）
SELECT * FROM exams ORDER BY year;

-- 範例 2：依年度遞減排序
SELECT * FROM exams ORDER BY year DESC;

-- 範例 3：多欄位排序：先依年度由新到舊，同年度再依科目
SELECT * FROM exams ORDER BY year DESC, subject;
-- 結果：exam 5（113 網路概論）、4（113 計算機原理）、3、2、1
-- 只有 113 年有兩筆，subject 只決定這兩筆的順序；「網」的編碼比「計」小，所以網路概論在前

-- 範例 3-2：⚠️ 一個 DESC 只管一個欄位，和範例 3 比較看看
SELECT exam_id, year, subject FROM exams ORDER BY year, subject DESC;
-- 結果：exam 1（110）、2（111）、3（112）、4（113 計算機原理）、5（113 網路概論）
-- year 沒寫方向，是預設的 ASC（由舊到新）；只有 subject 是 DESC

-- 範例 4：依配分由高到低，同分再依 question_id
SELECT question_id, score, content
FROM questions
ORDER BY score DESC, question_id;

-- 範例 5：NULL 在 SQLite 排序時被當成最小值
SELECT question_id, answer FROM questions
ORDER BY answer
LIMIT 5;

-- 範例 6：最新的 3 筆作答紀錄
SELECT * FROM practice_log
ORDER BY answered_at DESC
LIMIT 3;

-- 範例 7：分頁：每頁 10 題，第 2 頁
SELECT question_id, content FROM questions
ORDER BY question_id
LIMIT 10 OFFSET 10;

-- 範例 8：可以依計算結果排序
SELECT question_id, score, score * 2 FROM questions
ORDER BY score * 2 DESC
LIMIT 5;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：查出所有章節（topics），依名稱排序


-- 練習 2：查出 exam_id = 2 的題目，依題號（question_no）由大到小排序


-- 練習 3：查出配分最高的 3 題（同分時 question_id 小的排前面）


-- 練習 4：查出最早的一筆作答紀錄


-- 練習 5：題目依 question_id 排序，每頁 8 題，查出第 3 頁


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT * FROM topics ORDER BY name;

-- 練習 2
SELECT * FROM questions WHERE exam_id = 2 ORDER BY question_no DESC;

-- 練習 3
SELECT * FROM questions ORDER BY score DESC, question_id LIMIT 3;
-- 結果：第 4、5、6 題（2.5 分）

-- 練習 4
SELECT * FROM practice_log ORDER BY answered_at LIMIT 1;

-- 練習 5
SELECT * FROM questions ORDER BY question_id LIMIT 8 OFFSET 16;
-- 第 3 頁要跳過前 2 頁 × 8 題 = 16 題

*/
