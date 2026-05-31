SELECT
    cid
FROM silver.cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;