-- Шаг 1: Очищае данные, если есть
TRUNCATE TABLE silver.prd_info;

-- Шаг 2: Заливаем новые данные
INSERT INTO silver.prd_info (
                             prd_id,
                             cat_id,
                             prd_key,
                             prd_nm,
                             prd_cost,
                             prd_line,
                             prd_start_dt,
                             prd_end_dt,
                             dw_create_date
)
WITH deduplicated_source AS (
        SELECT
        prd_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        ROW_NUMBER() over (PARTITION BY prd_id ORDER BY prd_start_dt DESC) as rn
    FROM bronze.prd_info
),
cleared_source AS (
    SELECT
        prd_id,
        REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id, -- Extract category ID
        SUBSTRING(TRIM(prd_key), 7, length(TRIM(prd_key))) AS prd_key,        -- Extract product key
        TRIM(prd_nm) as prd_nm,
        COALESCE(prd_cost,0) as prd_cost,
        CASE
            WHEN TRIM(LOWER(prd_line)) = 'm' THEN 'Mountain'
            WHEN TRIM(LOWER(prd_line)) = 'r' THEN 'Road'
            WHEN TRIM(LOWER(prd_line)) = 's' THEN 'Other Sales'
            WHEN TRIM(LOWER(prd_line)) = 't' THEN 'Touring'
        ELSE 'Unknown'
        END AS prd_line,
        prd_start_dt,
        LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)::DATE - 1 as prd_end_dt_clear
    FROM deduplicated_source
    WHERE rn = 1
)
SELECT
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt::DATE,
    prd_end_dt_clear,
    CURRENT_TIMESTAMP as dw_create_date
FROM cleared_source
WHERE prd_id is not NULL;
