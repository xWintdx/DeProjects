SELECT
    id,
    COUNT(*)
FROM silver.px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;