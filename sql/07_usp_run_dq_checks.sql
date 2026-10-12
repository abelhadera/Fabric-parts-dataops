-- Runs after dbo.usp_load_from_staging in the pipeline.
-- Logs every check to dbo.dq_log, then THROWs if any CRITICAL check failed,
-- so the pipeline run shows as Failed in the Monitoring hub instead of silently succeeding.
--
-- CRITICAL vs WARNING: only problems that make the data wrong to use fail the run.
-- Everything else is logged for review, to avoid alert fatigue.

CREATE PROCEDURE dbo.usp_run_dq_checks
AS
BEGIN
    DECLARE @run_at DATETIME2(6) = SYSUTCDATETIME();

    INSERT INTO dbo.dq_log (run_at, check_name, severity, failed_rows)

    -- CRITICAL: duplicate primary keys (Fabric keys are NOT ENFORCED, so nothing else stops these)
    SELECT @run_at, 'duplicate_customer_ids', 'CRITICAL', COUNT(*)
    FROM (SELECT customer_id FROM dbo.customers GROUP BY customer_id HAVING COUNT(*) > 1) d
    UNION ALL
    SELECT @run_at, 'duplicate_supplier_ids', 'CRITICAL', COUNT(*)
    FROM (SELECT supplier_id FROM dbo.suppliers GROUP BY supplier_id HAVING COUNT(*) > 1) d
    UNION ALL
    SELECT @run_at, 'duplicate_part_ids', 'CRITICAL', COUNT(*)
    FROM (SELECT part_id FROM dbo.products GROUP BY part_id HAVING COUNT(*) > 1) d
    UNION ALL
    SELECT @run_at, 'duplicate_order_ids', 'CRITICAL', COUNT(*)
    FROM (SELECT order_id FROM dbo.orders GROUP BY order_id HAVING COUNT(*) > 1) d
    UNION ALL
    SELECT @run_at, 'duplicate_order_item_ids', 'CRITICAL', COUNT(*)
    FROM (SELECT order_item_id FROM dbo.order_items GROUP BY order_item_id HAVING COUNT(*) > 1) d

    -- CRITICAL: keys that failed to convert (TRY_CAST returned NULL)
    UNION ALL
    SELECT @run_at, 'null_order_ids', 'CRITICAL', COUNT(*)
    FROM dbo.orders WHERE order_id IS NULL

    -- CRITICAL: empty strings converted to 1900-01-01 instead of NULL
    UNION ALL
    SELECT @run_at, 'bad_1900_ship_dates', 'CRITICAL', COUNT(*)
    FROM dbo.orders WHERE ship_date = '1900-01-01'

    -- WARNING: orphaned records (child rows pointing to a missing parent)
    UNION ALL
    SELECT @run_at, 'orphaned_orders', 'WARNING', COUNT(*)
    FROM dbo.orders o
    LEFT JOIN dbo.customers c ON o.customer_id = c.customer_id
    WHERE o.customer_id IS NOT NULL AND c.customer_id IS NULL
    UNION ALL
    SELECT @run_at, 'orphaned_order_items', 'WARNING', COUNT(*)
    FROM dbo.order_items oi
    LEFT JOIN dbo.products p ON oi.part_id = p.part_id
    WHERE p.part_id IS NULL

    -- WARNING: business-rule violations worth reviewing
    UNION ALL
    SELECT @run_at, 'negative_stock', 'WARNING', COUNT(*)
    FROM dbo.products WHERE quantity_on_hand < 0
    UNION ALL
    SELECT @run_at, 'zero_price_products', 'WARNING', COUNT(*)
    FROM dbo.products WHERE unit_price = 0;

    IF EXISTS (SELECT 1 FROM dbo.dq_log
               WHERE run_at = @run_at AND severity = 'CRITICAL' AND failed_rows > 0)
        THROW 50001, 'Data-quality check failed: CRITICAL issues found. See dbo.dq_log for this run.', 1;
END;

-- Manual test:
-- EXEC dbo.usp_run_dq_checks;
-- SELECT * FROM dbo.dq_log ORDER BY run_at DESC, severity, check_name;
