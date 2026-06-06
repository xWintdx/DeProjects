-- Шаг 1: Очищаем старые данные (чтобы при перезапуске не было задвоений)
TRUNCATE TABLE silver.loc_a101;

-- Шаг 2: Заливка новых данных
INSERT INTO silver.loc_a101 (
                    cid,
                    cntry
)
with deduplicated_source as (
    SELECT
        cid,
        cntry,
        row_number() over (partition by cid) as rn
    from bronze.loc_a101
    WHERE cid is not null
)
SELECT
    REPLACE(cid,'-','') as new_cid,
    CASE
        WHEN lower(trim(cntry)) in ('germany','de') THEN 'Germany'
        WHEN lower(trim(cntry)) in ('united states','usa','us') THEN 'United States'
        WHEN cntry is NULL or length(trim(cntry)) = 0 THEN 'Unknown'
        ELSE cntry
    END as cntry
FROM deduplicated_source
WHERE rn = 1;