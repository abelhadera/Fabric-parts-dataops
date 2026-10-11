-- Run after each pipeline run.

-- 1. Row counts must match source: 155, 15, 62, 307, 772.
SELECT 'customers' AS tbl, COUNT(*) AS cnt FROM dbo.customers
UNION ALL SELECT 'suppliers',   COUNT(*) FROM dbo.suppliers
UNION ALL SELECT 'products',    COUNT(*) FROM dbo.products
UNION ALL SELECT 'orders',      COUNT(*) FROM dbo.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM dbo.order_items;

-- 2. Conversion checks.
--    unshipped_orders ~30, bad_1900_dates must be 0, no_middle_name ~51.
SELECT
    (SELECT COUNT(*) FROM dbo.orders    WHERE ship_date IS NULL)        AS unshipped_orders,
    (SELECT COUNT(*) FROM dbo.orders    WHERE ship_date = '1900-01-01') AS bad_1900_dates,
    (SELECT COUNT(*) FROM dbo.customers WHERE middle_name IS NULL)      AS no_middle_name;

-- 3. Values present in staging that failed to convert (should return 0 rows).
SELECT order_id, ship_date
FROM stg.orders
WHERE NULLIF(ship_date, '') IS NOT NULL
  AND TRY_CAST(ship_date AS DATE) IS NULL;

-- 4. Schema check. Note uppercase: Fabric Warehouse names are case-sensitive.
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION;
