import csv
from pathlib import Path
import pandas as pd


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

scan_target_folders(['datasets'])