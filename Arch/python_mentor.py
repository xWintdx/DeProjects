import math
from math import isinf

import pandas as pd
import numpy as np
import logging
from pathlib import Path

def extract_and_clear_data (filename:str):
    try:
        total_amount = 0
        for chunk in pd.read_csv(filename,chunksize=2,dtype={'transaction_id':str, 'amount':float, 'status':str}, usecols=['transaction_id','amount','status']):
            total_amount += (chunk[chunk['status']=='SUCCESS'].amount.sum())
        return total_amount
    except pd.errors.EmptyDataError:
        raise Exception("Empty Data")
    except FileNotFoundError:
        raise Exception("File Not Found")
    except ValueError:
        raise Exception ("ValueError")


def filter_large_transactions(df: pd.DataFrame) -> pd.DataFrame:
    df_large = df[df['amount']>100].copy()
    if df['amount'].isna().any():
        print(f"Warning: Dropped {df['amount'].isna().sum()} rows with NaN amount")
    return df_large

def filter_success_transactions(df: pd.DataFrame) -> pd.DataFrame:
    df_success = df[df['status'].str.lower().str.replace(' ', '')=='success'].copy()
    return df_success

def deduplicate_transactions(df: pd.DataFrame) -> pd.DataFrame:
    df_unique = df.drop_duplicates(subset=['transaction_id'], keep='last').reset_index(drop=True).copy()
    return df_unique

def upsert_transactions(df_history: pd.DataFrame, df_new: pd.DataFrame) -> pd.DataFrame:
    df_history = pd.concat([df_history, df_new], ignore_index=True).drop_duplicates(subset=['transaction_id'], keep='last').reset_index(drop=True)
    return df_history

# История (вчерашнее состояние БД)
df_history = pd.DataFrame({
    'transaction_id': ['t1', 't2', 't3'],
    'amount': [100.0, 50.0, 200.0],
    'status': ['PENDING', 'SUCCESS', 'PENDING']
})

# Свежая выгрузка за сегодня
df_new = pd.DataFrame({
    'transaction_id': ['t1', 't4'], # t1 обновился, t4 - абсолютно новая
    'amount': [100.0, 300.0],
    'status': ['SUCCESS', 'SUCCESS'] # t1 поменял статус на SUCCESS
})

# upsert_transactions(df_history, df_new)

df_raw = pd.DataFrame({
    'transaction_id': ['t1', 't2', np.nan, 't4', np.nan],
    'amount': [100.0, np.nan, 200.0, 300.0, np.nan],
    'comment': [np.nan, 'refund', 'late', np.nan, np.nan]
})

def clean_missing_data(df: pd.DataFrame) -> pd.DataFrame:
    df = df.dropna(subset=['transaction_id','amount'],how='any').reset_index(drop=True).copy()
    return df

df_marketing = pd.DataFrame({
    'transaction_id': ['t1', 't2', 't3', 't4'],
    'amount': [100.0, 50.0, 200.0, 300.0],
    'discount_code': ['WINTER20', np.nan, np.nan, np.nan],
    'promo_code': [np.nan, 'VIP_USER', np.nan, np.nan],
    'referral_code': [np.nan, np.nan, np.nan, np.nan]
})

def filter_promo_transactions(df: pd.DataFrame) -> pd.DataFrame:
    df = df.dropna(subset=['discount_code','promo_code','referral_code'],how='all').reset_index(drop=True).copy()
    return df

df_orders = pd.DataFrame({
    'order_id': ['ord_1', 'ord_2', 'ord_3'],
    'base_price': [1000.0, 500.0, 100.0],
    'discount': [200.0, np.nan, 150.0]  # Внимание на ord_3!
})

def calculate_final_price(df: pd.DataFrame) -> pd.DataFrame:
    df['discount'] = df['discount'].fillna(0)
    df['final_price'] = df['base_price'] - df['discount']
    df['final_price'] = np.where(df['final_price'] < 0, 0, df['final_price'])
    assert (df['final_price'] >= 0).all(), "Критическая ошибка: цена ушла в минус!"
    assert (df['final_price'] <= df['base_price']).all(), "Критическая ошибка: цена со скидкой больше исходной!"
    return df

# @pytest.mark.parametrize("rate", [None, 0, float('nan')])
# def test_calculate_amount_usd_invalid_rate(rate):
#     df = pd.DataFrame({'amount': [100.0], 'category': ['food']})
#     with pytest.raises(ValueError):
#         calculate_amount_usd(df, rate)  # rate приходит из декоратора
#
# def test_calculate_amount_usd_missing_column():
#     df = pd.DataFrame({'category': ['food']})
#     with pytest.raises(ValueError):
#         calculate_amount_usd(df, 90)
#
# def test_calculate_amount_usd_returns_correct_result():
#     rate = 2.0
#     df = pd.DataFrame({'amount': [100.0], 'category': ['food']})
#     result = calculate_amount_usd(df, rate)
#     assert 'amount_usd' in result.columns
#     assert result['amount_usd'].iloc[0] == 50.0
#     assert result['amount_usd'].notna().all()

def calculate_amount_usd(df: pd.DataFrame, rate: float) -> pd.DataFrame:

    df_clean = df.copy()
    if rate is None or rate == 0 or math.isnan(rate):
        raise ValueError("Cannot calculate amount_usd without a rate!")

    if 'amount' not in df.columns:
        raise ValueError("Cannot calculate amount_usd without amount!")

    if df_clean['amount'].isna().any() or df_clean['category'].isna().any():
        original_length = len(df_clean)
        df_clean = df_clean.dropna(subset=['amount'], how='any').dropna(subset=['category'], how='any').reset_index(drop=True)
        logging.warning(f"Строк потеряно: {original_length - len(df_clean)}")

    df_clean = (df_clean
                .assign(amount_usd=lambda x: x['amount'] / rate)
                .assign(amount_category=lambda x: x['amount'].astype(str)+'_'+ x['category'])
                .assign(is_large=lambda x: x['amount_usd'] > 2.0)
                )

    assert (df_clean['amount'].astype(str)+'_'+df_clean['category'] == df_clean['amount_category']).all(), 'Ошибка трансфорации'
    return df_clean

    # assert (df_clean['amount_usd'].notna()).all(), "Критическая ошибка: Nan значение!"
    # assert not (np.isinf(df_clean['amount_usd'])).any(), "Критическая ошибка: Inf значение!"


df = pd.DataFrame({
    'order_id': [1, 2, 3, 4],
    'amount':   [100.0, 250.0, None, 80.0],
    'test': [False, False, False, False]
})


def save_result(df: pd.DataFrame,filepath:str):
    if not Path(filepath).parent.exists():
        raise ValueError(f"Директория не существует: {Path(filepath).parent}")
    df.to_csv(filepath, mode='w', index=False)
    logging.info(f"Строк записано в новый файл: {len(df)}")


def clean_orders(orders:list) -> list:
    if not orders:
        raise ValueError("Список пустой")

    orders_count_before = len(orders)
    cleaned_orders = []

    for order in orders:
        amount = order.get('amount')
        if amount is not None and not math.isnan(amount):
            category = order.get('category','unknown')
            cleaned_orders.append({**order, 'category': category})

    if orders_count_before != len(cleaned_orders):
        logging.warning(f"Было потеряно {orders_count_before - len(cleaned_orders)} записей")

    return cleaned_orders

orders = [
    {'id': 1, 'amount': 100.0, 'category': 'food'},
    {'id': 2, 'amount': 250.0},
    {'id': 3, 'amount': None, 'category': 'tech'},
    {'id': 4, 'category': 'food'},
    {'id': 5, 'amount': float('nan'), 'category': 'tech'},
    {'id': 6, 'amount': 200.0, 'category': 'tech'},
]
