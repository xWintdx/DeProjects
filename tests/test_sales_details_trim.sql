SELECT
    sls_ord_num,
    sls_prd_key
FROM silver.sales_details
WHERE sls_ord_num != trim(sls_ord_num) OR sls_prd_key != trim(sls_prd_key);