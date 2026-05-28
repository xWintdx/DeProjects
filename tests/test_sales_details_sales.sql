SELECT
    sls_ord_num,
    sls_prd_key,
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.sales_details
WHERE sls_sales != sls_quantity * sls_price;