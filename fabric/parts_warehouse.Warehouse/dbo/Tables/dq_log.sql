CREATE TABLE [dbo].[dq_log] (
    [run_at]      DATETIME2 (6) NULL,
    [check_name]  VARCHAR (50)  NULL,
    [severity]    VARCHAR (10)  NULL,
    [failed_rows] INT           NULL
);


GO