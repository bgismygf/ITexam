# 3-3 LEFT / RIGHT / FULL OUTER JOIN 🎯💼

## 問題

想列出「每一題的作答次數」，用 INNER JOIN：
```sql
SELECT q.question_id, COUNT(*)
FROM questions q
JOIN practice_log p ON q.question_id = p.question_id
GROUP BY q.question_id;
```
結果只有 9 題。**沒被作答過的 21 題不見了**，因為 INNER JOIN 只保留兩邊都對得上的資料。

這時候就需要 **OUTER JOIN（外部合併）**。

## 三種 OUTER JOIN

| 類型 | 保留哪邊的全部資料 | 對不上的地方 |
|---|---|---|
| `LEFT JOIN` | **左表**（FROM 後面那張）全部保留 | 右表欄位填 NULL |
| `RIGHT JOIN` | **右表**（JOIN 後面那張）全部保留 | 左表欄位填 NULL |
| `FULL OUTER JOIN` | **兩邊**全部保留 | 對不上的那邊填 NULL |

`LEFT JOIN` 也可以寫成 `LEFT OUTER JOIN`，`OUTER` 可省略。

```
INNER JOIN         LEFT JOIN          RIGHT JOIN         FULL OUTER JOIN
 A    B             A    B             A    B             A    B
┌──┬──┬──┐        ┌──┬──┬──┐        ┌──┬──┬──┐        ┌──┬──┬──┐
│  │██│  │        │██│██│  │        │  │██│██│        │██│██│██│
└──┴──┴──┘        └──┴──┴──┘        └──┴──┴──┘        └──┴──┴──┘
```

## LEFT JOIN 範例

```sql
SELECT q.question_id, p.log_id, p.is_correct
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id;
```

| question_id | log_id | is_correct |
|---|---|---|
| 1 | 1 | 1 |
| 2 | 2 | 0 |
| 3 | **NULL** | **NULL** | ← 第 3 題沒被作答過，右表欄位是 NULL
| ... | ... | ... |

### 每題作答次數（包含 0 次）

```sql
SELECT q.question_id, COUNT(p.log_id) AS 作答次數
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id
GROUP BY q.question_id;
```

⚠️ 這裡要用 `COUNT(p.log_id)`，不能用 `COUNT(*)`：
- `COUNT(*)` 會把「填 NULL 的那一列」也算成 1
- `COUNT(p.log_id)` 忽略 NULL，沒作答的題目才會是 0

## 💼 經典用法：找出「沒有對應資料」的列

```sql
-- 從來沒被作答過的題目
SELECT q.question_id, q.content
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id
WHERE p.log_id IS NULL;
```

這個 **LEFT JOIN + IS NULL** 的寫法在工作上非常常用：
- 沒有下過訂單的會員
- 沒有被指派任務的員工
- 匯入資料時，找出對不到主檔的資料

## ⚠️ 陷阱：條件放 ON 還是 WHERE

對 LEFT JOIN 來說，**右表的條件**放在 ON 和 WHERE，結果不一樣：

```sql
-- A：條件放 ON → 每一題都保留，只是「答對的紀錄」才接上
SELECT q.question_id, p.log_id
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id AND p.is_correct = 1;

-- B：條件放 WHERE → 先 LEFT JOIN，再把 is_correct 不是 1 的列（包括 NULL）篩掉
--    結果變得跟 INNER JOIN 一樣，LEFT JOIN 白寫了
SELECT q.question_id, p.log_id
FROM questions q
LEFT JOIN practice_log p ON q.question_id = p.question_id
WHERE p.is_correct = 1;
```

**原則**：想要保留左表全部資料時，右表的篩選條件要放在 **ON**。

## RIGHT JOIN 與 FULL OUTER JOIN

- `A RIGHT JOIN B` 等於 `B LEFT JOIN A`。實務上大家幾乎都用 LEFT JOIN，
  把「要全部保留的表」放在左邊，比較好讀
- `FULL OUTER JOIN` 用在兩邊都可能有對不上的資料，例如比對兩份名單的差異

> ⚠️ SQLite 3.39 版（2022 年）才支援 RIGHT 和 FULL OUTER JOIN。
> 如果 DB Browser 執行時出現錯誤，表示內建的 SQLite 版本太舊，請更新 DB Browser。
> **MySQL 不支援 FULL OUTER JOIN**，要用 `LEFT JOIN ... UNION ... RIGHT JOIN` 代替。

## 小測驗

1. 表 A 有 5 筆資料，表 B 有 3 筆。A LEFT JOIN B 的結果至少有幾筆？
   (A) 0 (B) 3 (C) 5 (D) 15

2. 要找出「從未下訂單的客戶」，下列何者正確？（customers c, orders o）
   (A) `c JOIN o ON c.id = o.cid WHERE o.id IS NULL`
   (B) `c LEFT JOIN o ON c.id = o.cid WHERE o.id IS NULL`
   (C) `c LEFT JOIN o ON c.id = o.cid WHERE o.id IS NOT NULL`
   (D) `c RIGHT JOIN o ON c.id = o.cid WHERE c.id IS NULL`

<details>
<summary>看答案</summary>

1. **(C)**。LEFT JOIN 保留左表全部 5 筆；如果一筆對到多筆，結果會更多
2. **(B)**
</details>
