-- Шаг 1: Очищаем старые данные (чтобы при перезапуске не было задвоений)
TRUNCATE TABLE silver.cust_az12;

-- Шаг 2: Заливка новых данных
INSERT INTO silver.cust_az12 (
                    cid,
                    bdate,
                    gen
)
WITH deduplicated_source as (
    SELECT
        cid,
        bdate,
        gen,
        row_number() over (partition by cid) as rn
    FROM bronze.cust_az12
    WHERE cid is not NULL
)
SELECT
    CASE
        WHEN substring(lower(trim(cid)),1, 3) = 'nas' THEN upper(replace(lower((cid)),'nas',''))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate::date > NOW() then null
        else bdate::date
    end as bdate,
    CASE
        WHEN lower(trim(gen)) in ('male','m') THEN 'Male'
        WHEN lower(trim(gen)) in ('female','f') THEN 'Female'
        ELSE 'Unknown'
    END AS gen
FROM deduplicated_source
WHERE rn = 1;