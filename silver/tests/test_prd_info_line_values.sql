SELECT
    prd_line
FROM silver.prd_info
WHERE prd_line NOT IN ('Mountain','Road','Other Sales','Touring','Unknown')