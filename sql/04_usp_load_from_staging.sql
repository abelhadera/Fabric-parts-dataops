-- Moves data from stg (all text) into dbo (typed).
--
-- NULLIF(col, '') runs before every TRY_CAST because blank CSV values can arrive as
-- empty strings, and TRY_CAST('' AS DATE) returns 1900-01-01 / TRY_CAST('' AS INT) returns 0.
-- TRY_CAST returns NULL for unconvertible values instead of failing the whole load.
--
-- Note: no TRUNCATE yet. Rerunning the pipeline appends duplicates; that is intentional
-- for the planned failure exercise and will be fixed afterwards.

CREATE PROCEDURE dbo.usp_load_from_staging
AS
BEGIN
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
