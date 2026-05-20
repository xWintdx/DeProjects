from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine, text

# Функция для записи csv в БД через pandas
def load_to_bronze(df: pd.DataFrame, table_name: str):
    engine = create_engine("postgresql+psycopg://admin:admin@localhost:5432/de_playground")

    try:
        with engine.connect() as connection:
            _ = connection.execute(text("SELECT 1"))
        with engine.begin() as conn:
            df.to_sql(table_name, conn, schema='bronze', if_exists='append', index=False)
    except Exception as e:
        raise e

# Функция для поиска файлов csv в папке
def scan_target_folders(folder_names):
    base_path = Path(__file__).resolve().parent

    for folder_name in folder_names:
        target_path = base_path / folder_name

        if not target_path.exists() or not target_path.is_dir():
            print(f"Ошибка: '{folder_name}' не существует или не является папкой. Пропускаем.")
            continue

        for item in target_path.iterdir():
            for value in item.iterdir():
                if value.is_file() and value.suffix == '.csv':
                    df = pd.read_csv(value, encoding='utf-8')
                    print(df.columns)
                    print(print(df.head(5)))
                    load_to_bronze(df, value.name.removesuffix(".csv").lower())

scan_target_folders(['datasets'])