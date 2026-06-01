SELECT COUNT(*) AS failed_rows
FROM silver.sales_details
WHERE sls_sales != sls_quantity * sls_price;