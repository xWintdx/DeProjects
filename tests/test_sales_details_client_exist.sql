WITH distinct_custid_in_sales AS (SELECT DISTINCT sls_cust_id as sci1
                         FROM silver.sales_details)
SELECT dcis.sci1, ci.cst_id
FROM distinct_custid_in_sales dcis
LEFT JOIN silver.cust_info ci ON ci.cst_id = dcis.sci1
WHERE ci.cst_id IS NULL OR dcis.sci1 IS NULL;