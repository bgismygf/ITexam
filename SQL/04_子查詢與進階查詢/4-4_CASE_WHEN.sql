-- =====================================================================
-- 4-4 CASE WHEN 條件運算
-- =====================================================================

-- 範例 1：搜尋式 CASE，配分分級
SELECT question_id, score,
       CASE
           WHEN score >= 2.5 THEN '高配分'
           WHEN score >= 2   THEN '一般'
           ELSE '低配分'
       END AS 配分等級
FROM questions
WHERE exam_id = 1;

-- 範例 2：簡單式 CASE，代碼轉文字
SELECT log_id, question_id,
       CASE is_correct WHEN 1 THEN '答對' WHEN 0 THEN '答錯' END AS 結果
FROM practice_log;

-- 範例 3：處理 NULL 要用搜尋式
SELECT question_id,
       CASE WHEN answer IS NULL THEN '待補' ELSE answer END AS 答案
FROM questions
WHERE exam_id = 5;

-- 範例 4：自訂排序：網路概論排前面
SELECT * FROM exams
ORDER BY CASE subject WHEN '網路概論' THEN 1 ELSE 2 END, year;

-- 範例 5：⭐ 條件計數（樞紐分析）：每份考試各答案的題數
SELECT exam_id,
       SUM(CASE WHEN answer = 'A' THEN 1 ELSE 0 END) AS A,
       SUM(CASE WHEN answer = 'B' THEN 1 ELSE 0 END) AS B,
       SUM(CASE WHEN answer = 'C' THEN 1 ELSE 0 END) AS C,
       SUM(CASE WHEN answer = 'D' THEN 1 ELSE 0 END) AS D,
       SUM(CASE WHEN answer IS NULL THEN 1 ELSE 0 END) AS 未輸入
FROM questions
GROUP BY exam_id;

-- 範例 6：條件計數的簡寫：COUNT 會忽略 NULL，所以沒有 ELSE 時結果是 NULL、不會被計算
SELECT exam_id,
       COUNT(CASE WHEN score > 2 THEN 1 END) AS 高配分題數,
       COUNT(*) AS 總題數
FROM questions
GROUP BY exam_id;

-- 範例 7：倒扣計分：答對得分、答錯倒扣 1/4（只有倒扣的考試）、未作答 0 分
SELECT p.log_id, q.question_id, q.score, p.is_correct, e.wrong_penalty,
       CASE
           WHEN p.is_correct = 1 THEN q.score
           WHEN e.wrong_penalty = 1 THEN -q.score / 4
           ELSE 0
       END AS 得分
FROM practice_log p
JOIN questions q ON p.question_id = q.question_id
JOIN exams e     ON q.exam_id = e.exam_id;


-- =====================================================================
-- 練習題
-- =====================================================================

-- 練習 1：列出所有考試，增加一欄「計分方式」：wrong_penalty = 1 顯示「答錯倒扣」，否則「不倒扣」


-- 練習 2：每個年度的「計算機原理份數」和「網路概論份數」（一列一個年度）


-- 練習 3：每天的作答次數、答對次數、答錯次數、答對率（用 CASE 計數）


-- 練習 4：題目依「章節數量」分類：屬於 1 個章節顯示「單一主題」，2 個以上顯示「跨主題」


-- =====================================================================
-- 解答
-- =====================================================================
/*

-- 練習 1
SELECT *, CASE wrong_penalty WHEN 1 THEN '答錯倒扣' ELSE '不倒扣' END AS 計分方式
FROM exams;

-- 練習 2
SELECT year,
       SUM(CASE WHEN subject = '計算機原理' THEN 1 ELSE 0 END) AS 計算機原理,
       SUM(CASE WHEN subject = '網路概論'   THEN 1 ELSE 0 END) AS 網路概論
FROM exams
GROUP BY year;

-- 練習 3
SELECT substr(answered_at, 1, 10) AS 日期,
       COUNT(*) AS 作答,
       SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) AS 答對,
       SUM(CASE WHEN is_correct = 0 THEN 1 ELSE 0 END) AS 答錯,
       ROUND(AVG(CASE WHEN is_correct = 1 THEN 1.0 ELSE 0 END), 2) AS 答對率
FROM practice_log
GROUP BY substr(answered_at, 1, 10);

-- 練習 4
SELECT question_id,
       CASE WHEN COUNT(*) >= 2 THEN '跨主題' ELSE '單一主題' END AS 分類
FROM question_topics
GROUP BY question_id;

*/
