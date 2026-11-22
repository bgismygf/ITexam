"""
10-1 用 Python 連資料庫、參數化查詢

執行方式：在 VS Code 打開本檔，按右上角 ▶；
         或在終端機輸入  python "10_實戰與延伸/10-1_Python連資料庫.py"
本程式只會「讀取」題庫，不會修改 exam.db。
"""
import sqlite3
from pathlib import Path

# 不管從哪個資料夾執行，都能找到 data/exam.db
DB_PATH = Path(__file__).resolve().parent.parent / "data" / "exam.db"


def line(title):
    print("\n" + "=" * 60)
    print(title)
    print("=" * 60)


# ---------------------------------------------------------------------
# 範例 1：基本查詢
# ---------------------------------------------------------------------
line("範例 1：查詢所有考試")

conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

cur.execute("SELECT exam_id, year, subject, question_count FROM exams")
for exam_id, year, subject, count in cur.fetchall():
    print(f"[{exam_id}] {year} 年 {subject}，共 {count} 題")

# ---------------------------------------------------------------------
# 範例 2：參數化查詢
# ---------------------------------------------------------------------
line("範例 2：參數化查詢：113 年網路概論的題目")

year = 113
subject = "網路概論"
cur.execute(
    """
    SELECT q.question_no, q.content
    FROM questions q
    JOIN exams e ON q.exam_id = e.exam_id
    WHERE e.year = ? AND e.subject = ?
    ORDER BY q.question_no
    """,
    (year, subject),
)
for no, content in cur.fetchall():
    print(f"第 {no} 題：{content}")

# ---------------------------------------------------------------------
# 範例 3：fetchone 取得單一結果
# ---------------------------------------------------------------------
line("範例 3：fetchone 取得單一值")

cur.execute("SELECT COUNT(*) FROM questions")
total = cur.fetchone()[0]
print(f"題庫共有 {total} 題")

# ---------------------------------------------------------------------
# 範例 4：把結果轉成字典（用欄位名稱取值，比用位置清楚）
# ---------------------------------------------------------------------
line("範例 4：row_factory，用欄位名稱取值")

conn.row_factory = sqlite3.Row
cur = conn.cursor()
cur.execute("SELECT * FROM questions WHERE question_id = ?", (19,))
row = cur.fetchone()
print(dict(row))
print("題目內容：", row["content"])
print("答案：", row["answer"])
conn.row_factory = None
conn.close()

# ---------------------------------------------------------------------
# 範例 5：SQL Injection 的差別（用記憶體中的臨時資料庫示範）
# ---------------------------------------------------------------------
line("範例 5：SQL Injection：字串串接 vs 參數化")

mem = sqlite3.connect(":memory:")       # 記憶體資料庫，程式結束就消失
mem.executescript(
    """
    CREATE TABLE users (username TEXT, password TEXT);
    INSERT INTO users VALUES ('admin', 'S3cret!'), ('ming', '1234');
    """
)

attack = "' OR '1'='1' --"
print(f"攻擊者在帳號欄輸入：{attack}")

# ❌ 字串串接
unsafe_sql = f"SELECT * FROM users WHERE username = '{attack}' AND password = 'x'"
print("\n❌ 串接後的 SQL：", unsafe_sql)
print("   查到：", mem.execute(unsafe_sql).fetchall(), "← 不用密碼就查出所有帳號！")

# ✅ 參數化
safe_sql = "SELECT * FROM users WHERE username = ? AND password = ?"
print("\n✅ 參數化的 SQL：", safe_sql)
print("   查到：", mem.execute(safe_sql, (attack, "x")).fetchall(), "← 攻擊字串只被當成一般的值")

# ---------------------------------------------------------------------
# 範例 6：交易：with 區塊自動 commit / rollback
# ---------------------------------------------------------------------
line("範例 6：交易")

mem.executescript(
    """
    CREATE TABLE accounts (id TEXT PRIMARY KEY, balance INTEGER CHECK (balance >= 0));
    INSERT INTO accounts VALUES ('A', 5000), ('B', 3000);
    """
)
mem.commit()


def transfer(conn, from_id, to_id, amount):
    try:
        with conn:      # 區塊內全部成功 → commit；發生例外 → rollback
            conn.execute("UPDATE accounts SET balance = balance - ? WHERE id = ?", (amount, from_id))
            cur = conn.execute("UPDATE accounts SET balance = balance + ? WHERE id = ?", (amount, to_id))
            if cur.rowcount != 1:
                raise ValueError(f"收款帳號 {to_id} 不存在")
        print(f"✅ {from_id} 轉 {amount} 給 {to_id} 成功")
    except (sqlite3.IntegrityError, ValueError) as e:
        print(f"❌ {from_id} 轉 {amount} 給 {to_id} 失敗，已回復：{e}")
    print("   目前餘額：", mem.execute("SELECT * FROM accounts").fetchall())


transfer(mem, "A", "B", 1000)    # 成功
transfer(mem, "A", "B", 99999)   # 餘額不足，違反 CHECK → 回復
transfer(mem, "A", "C", 500)     # 帳號不存在 → 回復（A 不會被扣錢）

mem.close()

# =====================================================================
# 練習題（請自己在下面寫寫看）
# =====================================================================
# 練習 1：讓使用者輸入一個關鍵字，用參數化查詢找出題目內容包含該關鍵字的題目
#        提示：LIKE 的 % 要放在參數裡：cur.execute("... LIKE ?", (f"%{keyword}%",))
#
# 練習 2：查出每個章節的題數，印成「資料庫：8 題」的格式
#
# 解答：
# keyword = input("請輸入關鍵字：")
# conn = sqlite3.connect(DB_PATH)
# for qid, content in conn.execute(
#         "SELECT question_id, content FROM questions WHERE content LIKE ?", (f"%{keyword}%",)):
#     print(qid, content)
#
# for name, cnt in conn.execute("""
#         SELECT t.name, COUNT(*) FROM question_topics qt
#         JOIN topics t ON qt.topic_id = t.topic_id GROUP BY t.name"""):
#     print(f"{name}：{cnt} 題")
# conn.close()
