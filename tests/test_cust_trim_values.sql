SELECT
    cst_firstname,
    cst_lastname,
    cst_gndr
FROM silver.cust_info
WHERE cst_firstname != trim(cst_firstname) OR cst_lastname != trim(cst_lastname) OR
cst_gndr != trim(cst_gndr);