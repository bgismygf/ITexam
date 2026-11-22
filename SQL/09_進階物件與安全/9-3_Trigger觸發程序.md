# 9-3 Trigger 觸發程序 🎯💼

## 觀念

**觸發程序（Trigger）** 是「**當某個事件發生時，自動執行的程式**」。

例如：
- **每次新增作答紀錄時** → 自動更新題目的作答次數
- **每次修改題目答案時** → 自動記錄修改歷史
- **每次刪除資料前** → 檢查是否允許刪除

💡 **類比**：家裡的感應燈，有人經過（事件）就自動開燈（動作）。

## 三要素（ECA 規則）

| 要素 | 說明 | 例子 |
|---|---|---|
| **事件**（Event） | 什麼操作觸發 | `INSERT`、`UPDATE`、`DELETE` |
| **條件**（Condition） | 符合什麼條件才執行（可省略） | `WHEN NEW.is_correct = 0` |
| **動作**（Action） | 要執行的 SQL | 更新統計、寫入紀錄 |

## 觸發時機

| 時機 | 說明 | 常見用途 |
|---|---|---|
| `BEFORE` | 在操作**之前**執行 | 檢查、修正要寫入的資料 |
| `AFTER` | 在操作**之後**執行 | 記錄歷史、更新其他表 |
| `INSTEAD OF` | **取代**原本的操作 | 讓 View 可以被更新 |

## NEW 與 OLD

在 Trigger 中可以取得「被修改的那一列」的資料：

| 事件 | `OLD`（修改前） | `NEW`（修改後） |
|---|:-:|:-:|
| INSERT | ❌ | ✅ |
| UPDATE | ✅ | ✅ |
| DELETE | ✅ | ❌ |

> SQL Server 不是用 OLD / NEW，而是用 `deleted` 和 `inserted` 兩張虛擬表。

## SQLite 語法

```sql
CREATE TRIGGER 名稱
AFTER INSERT ON practice_log
FOR EACH ROW
WHEN 條件               -- 可省略
BEGIN
    SQL 敘述;
    SQL 敘述;
END;
```

## 🎯 列層級 vs 敘述層級

| | 列層級（Row-level） | 敘述層級（Statement-level） |
|---|---|---|
| 執行次數 | 每**一列**被影響就執行一次 | 每**一句 SQL** 只執行一次 |
| 語法 | `FOR EACH ROW` | `FOR EACH STATEMENT` |
| 例子 | `UPDATE` 改了 100 列 → 執行 100 次 | `UPDATE` 改了 100 列 → 執行 1 次 |

SQLite 只支援列層級；SQL Server 的 Trigger 是敘述層級。

## 💼 常見用途

1. **稽核紀錄（Audit Log）**：記錄誰、什麼時候、改了什麼。**政府機關、國營事業很常要求**
2. **維持衍生資料一致**：例如 6-7 課的反正規化欄位自動更新
3. **複雜的完整性檢查**：CHECK 做不到的跨表檢查
4. **自動填值**：例如自動設定 `updated_at`

## ⚠️ 注意事項

- Trigger 是「**看不見的程式**」：別人修改資料時，不知道背後會自動做了什麼事，
  **除錯困難**
- Trigger 中再觸發其他 Trigger（連鎖觸發），可能造成效能問題甚至無限迴圈
- 大量資料操作時，列層級 Trigger 會執行非常多次，**拖慢效能**
- 💼 原則：**能用限制條件（CHECK、FK）就不要用 Trigger**；業務邏輯盡量放在應用程式

## 小測驗

1. 在 UPDATE 觸發程序中，要取得「修改前」的資料，應使用？
   (A) NEW (B) OLD (C) BEFORE (D) INSERTED

2. 下列何者不是觸發程序的觸發事件？
   (A) INSERT (B) UPDATE (C) DELETE (D) SELECT

3. 讓原本不可更新的 View 可以接受 INSERT，可使用哪一種觸發程序？
   (A) BEFORE (B) AFTER (C) INSTEAD OF (D) FOR EACH STATEMENT

<details>
<summary>看答案</summary>

1. **(B)**
2. **(D)**。SELECT 不會觸發 Trigger
3. **(C)**
</details>
