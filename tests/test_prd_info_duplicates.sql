SELECT
    prd_id,
    prd_start_dt,
    COUNT(*)
FROM silver.prd_info
GROUP BY prd_id,prd_start_dt
HAVING COUNT(*) > 1;