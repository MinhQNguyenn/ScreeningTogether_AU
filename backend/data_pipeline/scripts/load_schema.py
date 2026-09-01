import psycopg2
from dotenv import load_dotenv
import os
from pathlib import Path
 
load_dotenv()
conn = psycopg2.connect(os.getenv("DATABASE_URL"))
cur = conn.cursor()
 
schema_path = Path(__file__).resolve().parent / "schema.sql"
with open(schema_path, "r") as f:
    cur.execute(f.read())
 
conn.commit()
cur.close()
conn.close()
print("Schema created successfully")