SELECT
    cst_id,
    COUNT(*)
FROM silver.cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;