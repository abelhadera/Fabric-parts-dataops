-- FIX for duplicate load on rerun
-- Run this only AFTER the deliberate failure has been captured.
--
-- Root cause: the copy activities append into stg.*, and usp_load_from_staging appends into dbo.*.
-- Each rerun stacked another full copy of the data on top of the last one.
--
-- Fix, part 1 (this script): the load procedure clears dbo before reloading (full reload).
-- Fix, part 2 (pipeline): each copy activity gets a pre-copy script, e.g.
--     TRUNCATE TABLE stg.customers;

-- Trade-off: truncate-and-reload is simple and right for small tables. For large tables,
-- an incremental load with MERGE (update changed rows, insert new ones) would be the better design.

CREATE PROCEDURE dbo.usp_load_from_staging
AS
BEGIN
    TRUNCATE TABLE dbo.order_items;
    TRUNCATE TABLE dbo.orders;
    TRUNCATE TABLE dbo.products;
    TRUNCATE TABLE dbo.suppliers;
    TRUNCATE TABLE dbo.customers;

    INSERT INTO dbo.customers (customer_id, first_name, last_name, email, phone, city, state, signup_date, middle_name)
    SELECT TRY_CAST(NULLIF(customer_id, '') AS INT),
           NULLIF(first_name, ''), NULLIF(last_name, ''), NULLIF(email, ''), NULLIF(phone, ''),
           NULLIF(city, ''), NULLIF(state, ''),
           TRY_CAST(NULLIF(signup_date, '') AS DATE),
           NULLIF(middle_name, '')
    FROM stg.customers;

    INSERT INTO dbo.suppliers (supplier_id, supplier_name, contact_email, city, state)
    SELECT TRY_CAST(NULLIF(supplier_id, '') AS INT),
           NULLIF(supplier_name, ''), NULLIF(contact_email, ''), NULLIF(city, ''), NULLIF(state, '')
    FROM stg.suppliers;

    INSERT INTO dbo.products (part_id, sku, part_name, category, supplier_id, unit_price, quantity_on_hand)
    SELECT TRY_CAST(NULLIF(part_id, '') AS INT),
           NULLIF(sku, ''), NULLIF(part_name, ''), NULLIF(category, ''),
           TRY_CAST(NULLIF(supplier_id, '') AS INT),
           TRY_CAST(NULLIF(unit_price, '') AS DECIMAL(10,2)),
           TRY_CAST(NULLIF(quantity_on_hand, '') AS INT)
    FROM stg.products;

    INSERT INTO dbo.orders (order_id, customer_id, order_date, status, ship_state, ship_date)
    SELECT TRY_CAST(NULLIF(order_id, '') AS INT),
           TRY_CAST(NULLIF(customer_id, '') AS INT),
           TRY_CAST(NULLIF(order_date, '') AS DATE),
           NULLIF(status, ''), NULLIF(ship_state, ''),
           TRY_CAST(NULLIF(ship_date, '') AS DATE)
    FROM stg.orders;

    INSERT INTO dbo.order_items (order_item_id, order_id, part_id, quantity, unit_price)
    SELECT TRY_CAST(NULLIF(order_item_id, '') AS INT),
           TRY_CAST(NULLIF(order_id, '') AS INT),
           TRY_CAST(NULLIF(part_id, '') AS INT),
           TRY_CAST(NULLIF(quantity, '') AS INT),
           TRY_CAST(NULLIF(unit_price, '') AS DECIMAL(10,2))
    FROM stg.order_items;
END;

GO