SELECT
    prd_key,
    prd_start_dt,
    prd_end_dt
FROM silver.prd_info
WHERE prd_end_dt < prd_start_dt;