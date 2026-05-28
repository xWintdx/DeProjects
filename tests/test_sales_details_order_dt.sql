SELECT
    sls_ord_num,
    sls_prd_key,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM silver.sales_details
WHERE sls_ship_dt < sls_order_dt OR sls_order_dt > sls_due_dt;