-- Шаг 1: Очищаем старые данные (чтобы при перезапуске не было задвоений)
TRUNCATE TABLE silver.px_cat_g1v2;

-- Шаг 2: Заливка новых данных
INSERT INTO silver.px_cat_g1v2 (
                id,
                cat,
                subcat,
                maintenance
)
with deduplicated_source as (
    SELECT
    id,
    cat,
    subcat,
    maintenance,
    row_number() over (PARTITION BY id) as rn
    FROM bronze.px_cat_g1v2
    WHERE id IS NOT NULL
)
SELECT
    trim(id) as id,
    trim(cat) as cat,
    trim(subcat) as subcat,
    trim(maintenance) as maintenance
FROM deduplicated_source
WHERE rn = 1;