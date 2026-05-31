from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine
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

# Функция для записи csv в БД через pandas
def load_to_bronze(df: pd.DataFrame, table_name: str, engine):
    with engine.begin() as conn:
        df.to_sql(table_name, conn, schema='bronze', if_exists='replace', index=False)

# Функция для поиска файлов csv в папке
def scan_target_folders(folder_names,engine):
    base_path = Path(__file__).resolve().parent

    for folder_name in folder_names:
        target_path = base_path / folder_name

        if not target_path.exists() or not target_path.is_dir():
            print(f"Ошибка: '{folder_name}' не существует или не является папкой. Пропускаем.")
            continue

        for item in target_path.iterdir():
            if item.is_dir():
                for value in item.iterdir():
                    if value.is_file() and value.suffix == '.csv':
                        df = pd.read_csv(value)
                        df.columns = df.columns.str.lower()
                        load_to_bronze(df, value.name.removesuffix(".csv").lower(), engine)

scan_target_folders(['datasets'],engine)