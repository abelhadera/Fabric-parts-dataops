CREATE TABLE [dbo].[products] (
    [part_id]          INT             NOT NULL,
    [sku]              VARCHAR (20)    NULL,
    [part_name]        VARCHAR (100)   NULL,
    [category]         VARCHAR (50)    NULL,
    [supplier_id]      INT             NULL,
    [unit_price]       DECIMAL (10, 2) NULL,
    [quantity_on_hand] INT             NULL
);


GO

ALTER TABLE [dbo].[products]
    ADD CONSTRAINT [pk_products] PRIMARY KEY NONCLUSTERED ([part_id] ASC) NOT ENFORCED;


GO