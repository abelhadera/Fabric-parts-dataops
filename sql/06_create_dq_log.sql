-- Data-quality results table. One row per check per run, so quality can be tracked over time.
-- DATETIME2(6): Fabric Warehouse doesn't support DATETIME for tables.

CREATE TABLE dbo.dq_log (
    run_at       DATETIME2(6),
    check_name   VARCHAR(50),
    severity     VARCHAR(10),   -- CRITICAL fails the pipeline; WARNING is logged only
    failed_rows  INT
);
