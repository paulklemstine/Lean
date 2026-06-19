import sqlite3

def search():
    path = 'Aether/Archive/catalog.sqlite'
    try:
        conn = sqlite3.connect(path)
        c = conn.cursor()
        c.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = [t[0] for t in c.fetchall()]
        print(f"Tables: {tables}")
        for t in tables:
            try:
                c.execute(f"SELECT * FROM {t} LIMIT 1")
                cols = [desc[0] for desc in c.description]
                for col in cols:
                    c.execute(f"SELECT * FROM {t} WHERE {col} LIKE '%a449aa2a%'")
                    rows = c.fetchall()
                    if rows:
                        print(f"Table: {t}, Col: {col}")
                        for row in rows:
                            print(f"  Row: {row}")
            except Exception as e:
                print(f"Error table {t}: {e}")
    except Exception as e:
        print(f"Error db: {e}")

if __name__ == '__main__':
    search()
