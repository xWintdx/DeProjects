SELECT
    sls_ord_num,
    sls_prd_key,
    COUNT(*)
FROM silver.sales_details
GROUP BY sls_ord_num,sls_prd_key
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;