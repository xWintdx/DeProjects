SELECT
    cid
FROM silver.loc_a101
GROUP BY cid
HAVING COUNT(*) > 1;