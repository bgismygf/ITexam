# 3-5 Self Join 自我合併 💼

## 觀念

**Self Join** 是一張表**跟自己** JOIN。它不是新的語法，只是把同一張表取兩個不同的別名，
當成兩張表來用。

```sql
SELECT ...
FROM 表 AS a
JOIN 表 AS b ON a.欄位 = b.欄位;
```

**一定要用別名**，否則資料庫分不出是哪一個。

## 什麼時候會用到

### 1. 同一張表裡的資料互相比較

例如：找出「同一個科目、不同年度」的考試配對
```sql
SELECT a.year AS 年度1, b.year AS 年度2, a.subject
FROM exams a
JOIN exams b ON a.subject = b.subject AND a.year < b.year;
```
`a.year < b.year` 可以避免：
- 自己跟自己配對（110 和 110）
- 同一組出現兩次（110-111 和 111-110）

### 2. 💼 階層資料（最經典）

員工表裡有「主管編號」，而主管本身也是員工：

| emp_id | name | manager_id |
|---|---|---|
| 1 | 王總經理 | NULL |
| 2 | 李經理 | 1 |
| 3 | 陳工程師 | 2 |

```sql
-- 列出每個員工和他的主管名字
SELECT e.name AS 員工, m.name AS 主管
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
```
用 LEFT JOIN，總經理（沒有主管）才不會消失。

其他階層資料的例子：部門與上層部門、商品分類與子分類、留言與回覆。

> 💡 階層很多層時（例如要查出某人底下的所有部屬），需要「遞迴 CTE」，第 4-5 課會介紹。

### 3. 比較相鄰的紀錄

例如「這次作答和上一次作答」。不過這種需求用**視窗函數 LAG()** 會更簡單（第 4-6 課）。

## 小測驗

1. 員工表 emp(id, name, manager_id) 中，要列出所有員工及其主管名稱（沒有主管也要列出），應使用？
   (A) emp e JOIN emp m ON e.id = m.manager_id
   (B) emp e LEFT JOIN emp m ON e.manager_id = m.id
   (C) emp e CROSS JOIN emp m
   (D) emp e RIGHT JOIN emp m ON e.id = m.id

<details>
<summary>看答案</summary>

**(B)**。e 是員工，m 是主管。員工的 manager_id 對應主管的 id；用 LEFT JOIN 保留沒有主管的人。
</details>
