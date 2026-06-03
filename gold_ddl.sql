CREATE SCHEMA IF NOT EXISTS gold;

DROP VIEW gold.dim_products;

CREATE OR REPLACE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() over (ORDER BY prd_key, prd_start_dt) as product_surrogate_key,
    pi.prd_key,
    pi.prd_nm,
    pi.prd_cost,
    pi.prd_start_dt,
    pi.prd_end_dt
FROM silver.prd_info pi
JOIN silver.px_cat_g1v2 g1v2 ON pi.cat_id = g1v2.id
UNION ALL
SELECT
    -1 AS product_surrogate_key,
    'Unknown' AS prd_key,
    'History Missing' AS prd_nm,
    0 AS prd_cost,
    '1900-01-01'::DATE AS prd_start_dt,
    NULL::DATE AS prd_end_dt;

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() over (ORDER BY cst_id) as product_surrogate_key,
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    az12.bdate,
    az12.gen,
    a101.cntry
FROM silver.cust_info ci
LEFT JOIN silver.cust_az12 az12 on ci.cst_key = az12.cid
LEFT JOIN silver.loc_a101 a101 on ci.cst_key = a101.cid;

CREATE VIEW gold.fact_sales AS
SELECT
    f.sls_ord_num,
    COALESCE(dim.product_surrogate_key, -1) AS product_surrogate_key,
    f.sls_quantity,
    f.sls_sales
FROM silver.sales_details f
LEFT JOIN gold.dim_products dim
  ON f.sls_prd_key = dim.prd_key
  AND f.sls_order_dt >= dim.prd_start_dt
  AND (f.sls_order_dt < dim.prd_end_dt OR dim.prd_end_dt IS NULL);