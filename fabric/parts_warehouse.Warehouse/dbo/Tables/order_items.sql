CREATE TABLE [dbo].[order_items] (
    [order_item_id] INT             NOT NULL,
    [order_id]      INT             NULL,
    [part_id]       INT             NULL,
    [quantity]      INT             NULL,
    [unit_price]    DECIMAL (10, 2) NULL
);


GO

ALTER TABLE [dbo].[order_items]
    ADD CONSTRAINT [pk_order_items] PRIMARY KEY NONCLUSTERED ([order_item_id] ASC) NOT ENFORCED;


GO