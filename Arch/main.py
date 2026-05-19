import pandas as pd
from sqlalchemy import create_engine, text, True_

def extract_and_clear_data (filename:str):
    try:
        df = pd.read_csv(filename, dtype={'order_id':'str', 'customer_id':'str', 'product_sku':'str',
                                          'quantity':'str', 'currency':'str', 'price':'str'}, parse_dates=['order_date'])
        if {'order_id','customer_id','product_sku',
            'quantity', 'currency','price','order_date'}.issubset(df.columns):
            df = df[['order_id','customer_id','product_sku',
            'quantity', 'currency','price','order_date']]
            df_clean = df[df['order_id'].notna() & df['price'].notna()]
            df_rejected = df[df['order_id'].isna() | df['price'].isna()]
            print(f"Skipped {len(df_rejected)} invalid rows. See quarantine table")
            df_clean['quantity'] = pd.to_numeric(df_clean['quantity'], errors='coerce')
            df_clean = df.drop(df_clean[df_clean['quantity'] < 0].index)
            df_clean['order_date'] = pd.to_datetime(df_clean['order_date'],format='mixed',errors='coerce')
            df_clean = df_clean.dropna(subset=['quantity','order_date']).reset_index(drop=True)
            df_clean = df_clean.drop_duplicates(subset=['order_id'], keep='first')
            engine = create_engine("postgresql+psycopg://de:de@localhost:5432/mentor_de")
            try:
                with engine.connect() as connection:
                    result = connection.execute(text("SELECT 1"))
                with engine.begin() as conn:
                    df_clean.to_sql('orders', conn, schema='test', if_exists='append', index=False)
            except Exception as e:
                print(f"Детали: {e}")
        else:
            raise Exception("Required columns are not in the current dataFrame")
    except pd.errors.EmptyDataError:
        raise Exception("Empty Data")
    except FileNotFoundError:
        raise Exception("File Not Found")
    except ValueError:
        raise Exception ("Something Went Wrong")

extract_and_clear_data("orders_raw_big.csv")