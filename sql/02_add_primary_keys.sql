-- Primary keys in Fabric Warehouse must be NONCLUSTERED and NOT ENFORCED.
-- They document intent and help the optimizer, but Fabric does NOT reject duplicate rows.
-- That is why duplicate detection has to live in the data-quality checks.

ALTER TABLE dbo.customers   ADD CONSTRAINT pk_customers   PRIMARY KEY NONCLUSTERED (customer_id)   NOT ENFORCED;
ALTER TABLE dbo.suppliers   ADD CONSTRAINT pk_suppliers   PRIMARY KEY NONCLUSTERED (supplier_id)   NOT ENFORCED;
ALTER TABLE dbo.products    ADD CONSTRAINT pk_products    PRIMARY KEY NONCLUSTERED (part_id)       NOT ENFORCED;
ALTER TABLE dbo.orders      ADD CONSTRAINT pk_orders      PRIMARY KEY NONCLUSTERED (order_id)      NOT ENFORCED;
ALTER TABLE dbo.order_items ADD CONSTRAINT pk_order_items PRIMARY KEY NONCLUSTERED (order_item_id) NOT ENFORCED;

-- Verify:
-- SELECT name FROM sys.key_constraints;
