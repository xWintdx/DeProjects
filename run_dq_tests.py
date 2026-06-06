from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine,text
import os
from dotenv import load_dotenv

load_dotenv()
user = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
port = os.getenv('DB_PORT')
db_name = os.getenv('DB_NAME')

db_url = f"postgresql+psycopg://{user}:{password}@{host}:{port}/{db_name}"

engine = create_engine(db_url)

# Функция для запуска скриптов
def run_file(filename, engine):
    with open(filename, 'r', encoding='utf-8') as file:
        sql_script = file.read()
    with engine.connect() as conn:
        query = text(sql_script)
        df = pd.read_sql_query(query, conn)
        if len(df) > 0:
            raise Exception(f"Data Quality Check Failed for {filename}")

# Функция для поиска файлов csv в папке
def scan_target_folders(folder_names, engine):
    base_path = Path(__file__).resolve().parent

    for folder_name in folder_names:
        target_path = base_path / folder_name

        if not target_path.exists() or not target_path.is_dir():
            print(f"Ошибка: '{folder_name}' не существует или не является папкой. Пропускаем.")
            continue

        for item in target_path.iterdir():
            if item.is_dir():
                for value in item.iterdir():
                    if value.suffix == '.sql':
                        run_file(value, engine)

        print("All DQ checks passed!")

scan_target_folders(['silver'], engine)