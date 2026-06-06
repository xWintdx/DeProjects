SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_quantity
FROM silver.sales_details
WHERE sls_ord_num IS NULL OR sls_prd_key IS NULL OR
      sls_cust_id IS NULL OR sls_quantity IS NULL;