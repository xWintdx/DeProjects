-- Шаг 1: Очищаем старые данные (чтобы при перезапуске не было задвоений)
TRUNCATE TABLE silver.sales_details;

-- Шаг 2: Заливаем новые чистые данные
INSERT INTO silver.sales_details (
                                  sls_ord_num,
                                  sls_prd_key,
                                  sls_cust_id,
                                  sls_order_dt,
                                  sls_ship_dt,
                                  sls_due_dt,
                                  sls_sales,
                                  sls_quantity,
                                  sls_price
)
WITH deduplicated_source AS (
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price,
        ROW_NUMBER() OVER (PARTITION BY sls_ord_num,sls_prd_key) as rn
    FROM bronze.sales_details
)
SELECT
    trim(sls_ord_num) as sls_ord_num,
    trim(sls_prd_key) as sls_prd_key,
    sls_cust_id,
    CASE
        WHEN sls_order_dt = 0 OR length(sls_order_dt::text)!=8 THEN NULL
        ELSE to_date(sls_order_dt::text, 'YYYYMMDD')
    END AS sls_order_dt,
    CASE
        WHEN sls_ship_dt = 0 OR length(sls_ship_dt::text)!=8 THEN NULL
        ELSE to_date(sls_ship_dt::text, 'YYYYMMDD')
    END AS sls_ship_dt,
    CASE
        WHEN sls_due_dt = 0 OR length(sls_due_dt::text)!=8 THEN NULL
        ELSE to_date(sls_due_dt::text, 'YYYYMMDD')
    END AS sls_due_dt,
    CASE
        WHEN sls_sales <=0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_price * sls_quantity
        ELSE sls_sales
    END AS sls_sales,
    CASE
        WHEN sls_price <=0 OR sls_price IS NULL THEN sls_sales / COALESCE(sls_quantity,0)
        ELSE sls_price
    END AS sls_price,
    sls_quantity
FROM deduplicated_source
WHERE rn = 1 AND sls_ord_num IS NOT NULL AND sls_cust_id IS NOT NULL