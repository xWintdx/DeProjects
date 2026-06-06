-- Шаг 1: Очищаем старые данные (чтобы при перезапуске не было задвоений)
TRUNCATE TABLE silver.cust_info;

-- Шаг 2: Заливаем новые чистые данные
INSERT INTO silver.cust_info (
                              cst_id,
                              cst_key,
                              cst_firstname,
                              cst_lastname,
                              cst_marital_status,
                              cst_gndr,
                              cst_create_date,
                              dw_create_date
)
WITH deduplicated_source AS (
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        cst_marital_status,
        CASE
            WHEN TRIM(LOWER(cst_gndr)) IN ('m', 'male') THEN 'Male'
            WHEN TRIM(LOWER(cst_gndr)) IN ('f', 'female') THEN 'Female'
            ELSE 'Unknown'
        END AS cst_gndr,
        CAST(cst_create_date AS DATE) AS cst_create_date,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as rn
    FROM bronze.cust_info
)
SELECT
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date,
    CURRENT_TIMESTAMP AS dw_create_date
FROM deduplicated_source
WHERE rn = 1 AND cst_id IS NOT NULL;