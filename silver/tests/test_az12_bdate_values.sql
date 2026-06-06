SELECT
    cid,
    bdate
FROM silver.cust_az12
WHERE bdate > NOW();