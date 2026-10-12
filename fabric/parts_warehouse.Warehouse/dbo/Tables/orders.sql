CREATE TABLE [dbo].[orders] (
    [order_id]    INT          NOT NULL,
    [customer_id] INT          NULL,
    [order_date]  DATE         NULL,
    [status]      VARCHAR (20) NULL,
    [ship_state]  VARCHAR (2)  NULL,
    [ship_date]   DATE         NULL
);


GO

ALTER TABLE [dbo].[orders]
    ADD CONSTRAINT [pk_orders] PRIMARY KEY NONCLUSTERED ([order_id] ASC) NOT ENFORCED;


GO