"""
10-3 綜合專題：題庫刷題程式

功能：
  1. 隨機練習：從題庫隨機抽題作答，自動判斷對錯並寫入 practice_log
  2. 錯題複習：只練「最近一次答錯」的題目
  3. 優先練習沒做過的題目
  4. 弱點分析報表：各章節答對率、各考試答對率

執行方式：在 VS Code 打開本檔按 ▶，或在終端機輸入
  python "10_實戰與延伸/10-3_刷題程式.py"
  python "10_實戰與延伸/10-3_刷題程式.py" --db 其他資料庫路徑.db

⚠️ 本程式會把作答紀錄寫入 data/exam.db 的 practice_log。
"""
import argparse
import sqlite3
from pathlib import Path

DEFAULT_DB = Path(__file__).resolve().parent.parent / "data" / "exam.db"

# ---------------------------------------------------------------------
# 選題用的 SQL（重點都在這裡，對照第 3、4 單元）
# ---------------------------------------------------------------------
SQL_RANDOM = """
    SELECT q.question_id, e.year, e.subject, q.question_no, q.content, q.answer
    FROM questions q
    JOIN exams e ON q.exam_id = e.exam_id
    WHERE q.answer IS NOT NULL
    ORDER BY random()
    LIMIT ?
"""

SQL_WRONG = """
    WITH ranked AS (
        SELECT question_id, is_correct,
               ROW_NUMBER() OVER (PARTITION BY question_id ORDER BY answered_at DESC, log_id DESC) AS rn
        FROM practice_log
    )
    SELECT q.question_id, e.year, e.subject, q.question_no, q.content, q.answer
    FROM ranked r
    JOIN questions q ON r.question_id = q.question_id
    JOIN exams e     ON q.exam_id = e.exam_id
    WHERE r.rn = 1 AND r.is_correct = 0 AND q.answer IS NOT NULL
    ORDER BY random()
    LIMIT ?
"""

SQL_UNPRACTICED = """
    SELECT q.question_id, e.year, e.subject, q.question_no, q.content, q.answer
    FROM questions q
    JOIN exams e ON q.exam_id = e.exam_id
    WHERE q.answer IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM practice_log p WHERE p.question_id = q.question_id)
    ORDER BY random()
    LIMIT ?
"""

SQL_OPTIONS = "SELECT label, content FROM options WHERE question_id = ? ORDER BY label"

SQL_INSERT_LOG = """
    INSERT INTO practice_log (question_id, answered_at, chosen, is_correct)
    VALUES (?, datetime('now', 'localtime'), ?, ?)
"""

SQL_TOPIC_REPORT = """
    SELECT t.name,
           COUNT(DISTINCT qt.question_id)                          AS 題數,
           COUNT(DISTINCT p.question_id)                           AS 做過,
           COUNT(p.log_id)                                         AS 作答次數,
           CAST(ROUND(AVG(p.is_correct) * 100) AS INTEGER) || '%'  AS 答對率
    FROM topics t
    LEFT JOIN question_topics qt ON t.topic_id = qt.topic_id
    LEFT JOIN practice_log p     ON qt.question_id = p.question_id
    GROUP BY t.topic_id, t.name
    ORDER BY AVG(p.is_correct) IS NULL, AVG(p.is_correct)
"""

SQL_EXAM_REPORT = """
    SELECT e.year || '年 ' || e.subject AS 考試,
           COUNT(DISTINCT q.question_id)    AS 題數,
           COUNT(DISTINCT p.question_id)    AS 做過,
           COUNT(p.log_id)                  AS 作答次數,
           CAST(ROUND(AVG(p.is_correct) * 100) AS INTEGER) || '%' AS 答對率
    FROM exams e
    JOIN questions q         ON e.exam_id = q.exam_id
    LEFT JOIN practice_log p ON q.question_id = p.question_id
    GROUP BY e.exam_id
    ORDER BY e.year, e.subject
"""


def ask(prompt, valid):
    """反覆詢問，直到輸入合法的值；輸入結束（EOF）時回傳 None"""
    while True:
        try:
            value = input(prompt).strip().upper()
        except EOFError:
            return None
        if value in valid:
            return value
        print(f"  請輸入 {' / '.join(valid)}")


def quiz(conn, sql, count):
    questions = conn.execute(sql, (count,)).fetchall()
    if not questions:
        print("\n沒有符合條件的題目。")
        return

    correct = 0
    for i, (qid, year, subject, no, content, answer) in enumerate(questions, 1):
        print(f"\n【第 {i}/{len(questions)} 題】{year} 年 {subject} 第 {no} 題")
        print(content)
        options = conn.execute(SQL_OPTIONS, (qid,)).fetchall()
        for label, text in options:
            print(f"  ({label}) {text}")

        chosen = ask("你的答案（A/B/C/D，Q 結束）：", [o[0] for o in options] + ["Q"])
        if chosen in (None, "Q"):
            break

        is_correct = 1 if chosen == answer else 0
        with conn:   # 交易：寫入成功才 commit
            conn.execute(SQL_INSERT_LOG, (qid, chosen, is_correct))

        if is_correct:
            correct += 1
            print("  ✔ 答對了！")
        else:
            answer_text = dict(options).get(answer, "")
            print(f"  ✘ 答錯了，正確答案是 ({answer}) {answer_text}")

    print(f"\n本次練習結束：答對 {correct} 題。")


def print_table(conn, sql, title):
    cur = conn.execute(sql)
    headers = [d[0] for d in cur.description]
    rows = cur.fetchall()
    print(f"\n=== {title} ===")
    print(" | ".join(headers))
    for row in rows:
        print(" | ".join("-" if v is None else str(v) for v in row))


def report(conn):
    print_table(conn, SQL_TOPIC_REPORT, "各章節答對率（由低到高，- 表示還沒做過）")
    print_table(conn, SQL_EXAM_REPORT, "各考試答對率")


def main():
    parser = argparse.ArgumentParser(description="題庫刷題程式")
    parser.add_argument("--db", default=str(DEFAULT_DB), help="資料庫路徑")
    args = parser.parse_args()

    if not Path(args.db).exists():
        print(f"找不到資料庫：{args.db}")
        return

    conn = sqlite3.connect(args.db)
    print(f"已連線：{args.db}")

    menu = {
        "1": ("隨機練習 10 題", lambda: quiz(conn, SQL_RANDOM, 10)),
        "2": ("錯題複習（最近一次答錯的題目）", lambda: quiz(conn, SQL_WRONG, 10)),
        "3": ("練習還沒做過的題目", lambda: quiz(conn, SQL_UNPRACTICED, 10)),
        "4": ("弱點分析報表", lambda: report(conn)),
        "0": ("離開", None),
    }

    while True:
        print("\n========== 題庫刷題 ==========")
        for key, (name, _) in menu.items():
            print(f"  {key}. {name}")
        choice = ask("請選擇：", list(menu))
        if choice in (None, "0"):
            break
        menu[choice][1]()

    conn.close()
    print("掰掰，明天見！")


if __name__ == "__main__":
    main()
