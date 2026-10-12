CREATE TABLE [dbo].[suppliers] (
    [supplier_id]   INT           NOT NULL,
    [supplier_name] VARCHAR (100) NULL,
    [contact_email] VARCHAR (100) NULL,
    [city]          VARCHAR (50)  NULL,
    [state]         VARCHAR (2)   NULL
);


GO

ALTER TABLE [dbo].[suppliers]
    ADD CONSTRAINT [pk_suppliers] PRIMARY KEY NONCLUSTERED ([supplier_id] ASC) NOT ENFORCED;


GO