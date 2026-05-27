-- 1. Создание схем
CREATE SCHEMA IF NOT EXISTS silver;

-- 2. Очистка (Опционально, для среды разработки)
DROP TABLE IF EXISTS silver.cust_info CASCADE;
DROP TABLE IF EXISTS silver.prd_info CASCADE;
DROP TABLE IF EXISTS silver.sales_details CASCADE;
DROP TABLE IF EXISTS silver.cust_az12 CASCADE;
DROP TABLE IF EXISTS silver.cust_az12 CASCADE;
DROP TABLE IF EXISTS silver.px_cat_g1v2 CASCADE;

-- 3. Создание таблиц
CREATE TABLE IF NOT EXISTS silver.cust_info (
    cst_id INTEGER PRIMARY KEY,
    cst_key VARCHAR(50) UNIQUE,
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
    dw_create_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

CREATE TABLE IF NOT EXISTS silver.prd_info (
    prd_id INTEGER PRIMARY KEY,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost NUMERIC,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dw_create_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

CREATE TABLE IF NOT EXISTS silver.sales_details (
    row_id SERIAL PRIMARY KEY,
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INTEGER,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales NUMERIC,
    sls_quantity INTEGER,
    sls_price NUMERIC,
    dw_create_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_prd_key_in_ord_num UNIQUE (sls_ord_num, sls_prd_key)
    );

CREATE TABLE IF NOT EXISTS silver.cust_az12 (
    CID VARCHAR(50) PRIMARY KEY,
    BDATE TIMESTAMP,
    GEN VARCHAR(50),
    dw_create_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

CREATE TABLE IF NOT EXISTS silver.loc_a101 (
    CID VARCHAR(50) PRIMARY KEY,
    CNTRY VARCHAR(50),
    dw_create_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

CREATE TABLE IF NOT EXISTS silver.px_cat_g1v2 (
    ID VARCHAR(50) PRIMARY KEY,
    CAT VARCHAR(50),
    SUBCAT VARCHAR(50),
    MAINTENANCE VARCHAR(50),
    dw_create_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );