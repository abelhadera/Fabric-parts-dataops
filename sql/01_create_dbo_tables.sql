-- Typed destination tables in the Fabric Warehouse (parts_warehouse).
-- Column order matches the source CSVs.
-- All types used here are supported by Fabric Warehouse; no translation from SQL Server was needed.
-- (DATETIME, NVARCHAR, MONEY and TINYINT would have needed converting.)

CREATE TABLE dbo.customers (
    customer_id  INT NOT NULL,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    email        VARCHAR(100),
    phone        VARCHAR(20),
    city         VARCHAR(50),
    state        VARCHAR(2),
    signup_date  DATE,
    middle_name  VARCHAR(50)
);

CREATE TABLE dbo.suppliers (
    supplier_id    INT NOT NULL,
    supplier_name  VARCHAR(100),
    contact_email  VARCHAR(100),
    city           VARCHAR(50),
    state          VARCHAR(2)
);

CREATE TABLE dbo.products (
    part_id           INT NOT NULL,
    sku               VARCHAR(20),
    part_name         VARCHAR(100),
    category          VARCHAR(50),
    supplier_id       INT,
    unit_price        DECIMAL(10,2),
    quantity_on_hand  INT
);

CREATE TABLE dbo.orders (
    order_id     INT NOT NULL,
    customer_id  INT,
    order_date   DATE,
    status       VARCHAR(20),
    ship_state   VARCHAR(2),
    ship_date    DATE
);

CREATE TABLE dbo.order_items (
    order_item_id  INT NOT NULL,
    order_id       INT,
    part_id        INT,
    quantity       INT,
    unit_price     DECIMAL(10,2)
);
