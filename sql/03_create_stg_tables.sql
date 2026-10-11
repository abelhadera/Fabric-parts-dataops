-- Staging layer: every column is VARCHAR so the copy activity never has to convert types.
-- Conversion happens afterwards in dbo.usp_load_from_staging.
-- Run CREATE SCHEMA on its own first.

CREATE SCHEMA stg;

CREATE TABLE stg.customers (
    customer_id VARCHAR(255), first_name VARCHAR(255), last_name VARCHAR(255),
    email VARCHAR(255), phone VARCHAR(255), city VARCHAR(255), state VARCHAR(255),
    signup_date VARCHAR(255), middle_name VARCHAR(255)
);

CREATE TABLE stg.suppliers (
    supplier_id VARCHAR(255), supplier_name VARCHAR(255), contact_email VARCHAR(255),
    city VARCHAR(255), state VARCHAR(255)
);

CREATE TABLE stg.products (
    part_id VARCHAR(255), sku VARCHAR(255), part_name VARCHAR(255), category VARCHAR(255),
    supplier_id VARCHAR(255), unit_price VARCHAR(255), quantity_on_hand VARCHAR(255)
);

CREATE TABLE stg.orders (
    order_id VARCHAR(255), customer_id VARCHAR(255), order_date VARCHAR(255),
    status VARCHAR(255), ship_state VARCHAR(255), ship_date VARCHAR(255)
);

CREATE TABLE stg.order_items (
    order_item_id VARCHAR(255), order_id VARCHAR(255), part_id VARCHAR(255),
    quantity VARCHAR(255), unit_price VARCHAR(255)
);
