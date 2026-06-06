SELECT
    prd_key,
    prd_nm
FROM silver.prd_info
WHERE prd_key != trim(prd_key) OR prd_nm != trim(prd_nm);