WITH distinct_prd_key_in_sales AS (SELECT DISTINCT sls_prd_key as spk
                         FROM silver.sales_details)
SELECT dpkis.spk, pi.prd_key
FROM distinct_prd_key_in_sales dpkis
LEFT JOIN silver.prd_info pi ON pi.prd_key = dpkis.spk
WHERE pi.prd_key IS NULL OR dpkis.spk IS NULL;