# 4-4 CASE WHEN 條件運算 💼

## 觀念

`CASE WHEN` 是 SQL 的「**如果…就…否則…**」，可以依條件產生不同的值。
類似 Excel 的 `IF()` 函數。

## 兩種寫法

### 1. 搜尋式 CASE（最常用）

```sql
CASE
    WHEN 條件1 THEN 結果1
    WHEN 條件2 THEN 結果2
    ELSE 其他結果
END
```

```sql
SELECT question_id, score,
       CASE
           WHEN score >= 2.5 THEN '高配分'
           WHEN score >= 2   THEN '一般'
           ELSE '低配分'
       END AS 配分等級
FROM questions;
```

### 2. 簡單式 CASE（比對單一欄位的值）

```sql
CASE 欄位
    WHEN 值1 THEN 結果1
    WHEN 值2 THEN 結果2
    ELSE 其他結果
END
```

```sql
SELECT log_id,
       CASE is_correct WHEN 1 THEN '✔ 答對' WHEN 0 THEN '✘ 答錯' END AS 結果
FROM practice_log;
```

## 規則

- 由上往下判斷，**第一個成立的 WHEN 就停止**，所以範圍條件要從嚴格到寬鬆排
- 沒有任何 WHEN 成立、又沒寫 ELSE 時，結果是 **NULL**
- 最後一定要寫 `END`
- 每個 THEN 的結果型態最好一致（都是文字或都是數字）
- ⚠️ 簡單式 CASE 無法判斷 NULL（`CASE x WHEN NULL` 永遠不成立），要用搜尋式 `WHEN x IS NULL`

## 💼 CASE 可以放在任何地方

### 放在 SELECT：轉換顯示

把代碼轉成看得懂的文字（工作上超常用）：`1 → 男`、`'P' → 處理中`

### 放在 ORDER BY：自訂排序

```sql
ORDER BY CASE subject WHEN '網路概論' THEN 1 WHEN '計算機原理' THEN 2 END
```

### ⭐ 放在彙總函數裡：條件計數（樞紐分析）

這是 CASE 最強大的用法，把「列」轉成「欄」：

```sql
SELECT exam_id,
       SUM(CASE WHEN answer = 'A' THEN 1 ELSE 0 END) AS A的題數,
       SUM(CASE WHEN answer = 'B' THEN 1 ELSE 0 END) AS B的題數,
       SUM(CASE WHEN answer = 'C' THEN 1 ELSE 0 END) AS C的題數,
       SUM(CASE WHEN answer = 'D' THEN 1 ELSE 0 END) AS D的題數
FROM questions
GROUP BY exam_id;
```

| exam_id | A的題數 | B的題數 | C的題數 | D的題數 |
|---|---|---|---|---|
| 1 | 0 | 3 | 3 | 0 |
| ... | | | | |

一次查詢就得到一張樞紐分析表，不用分成好幾次查。

### 放在 UPDATE：依條件更新不同的值（第 5 單元）

```sql
UPDATE questions SET score = CASE WHEN exam_id = 1 THEN 2 ELSE score END;
```

## 小測驗

1. 下列 SQL 中，score = 2.5 的題目會得到什麼結果？
   ```sql
   CASE WHEN score >= 2 THEN '一般' WHEN score >= 2.5 THEN '高' ELSE '低' END
   ```
   (A) 一般 (B) 高 (C) 低 (D) NULL

<details>
<summary>看答案</summary>

**(A)**。第一個 WHEN（score >= 2）就成立了，不會再往下判斷。正確寫法要把 `>= 2.5` 放前面。
</details>
