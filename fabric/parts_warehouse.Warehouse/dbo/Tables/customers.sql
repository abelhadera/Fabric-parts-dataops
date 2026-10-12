CREATE TABLE [dbo].[customers] (
    [customer_id] INT           NOT NULL,
    [first_name]  VARCHAR (50)  NULL,
    [last_name]   VARCHAR (50)  NULL,
    [email]       VARCHAR (100) NULL,
    [phone]       VARCHAR (20)  NULL,
    [city]        VARCHAR (50)  NULL,
    [state]       VARCHAR (2)   NULL,
    [signup_date] DATE          NULL,
    [middle_name] VARCHAR (50)  NULL
);


GO

ALTER TABLE [dbo].[customers]
    ADD CONSTRAINT [pk_customers] PRIMARY KEY NONCLUSTERED ([customer_id] ASC) NOT ENFORCED;


GO