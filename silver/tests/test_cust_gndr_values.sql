SELECT
    cst_gndr
FROM silver.cust_info
WHERE cst_gndr NOT IN ('Male','Female','Unknown');