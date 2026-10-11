# SQL Server vs. Fabric Warehouse: differences found

Behavior differences discovered while moving the `parts_practice` database from a local SQL Server (Docker) into a Fabric Warehouse.

| Area | SQL Server (local) | Fabric Warehouse | How it showed up |
|---|---|---|---|
| Name case sensitivity | Case-insensitive (default collation) | **Case-sensitive** (`Latin1_General_100_BIN2_UTF8`) | `information_schema.columns` failed with "Invalid object name"; had to use `INFORMATION_SCHEMA.COLUMNS` |
| String comparisons | `'smith' = 'Smith'` is true | Case-sensitive | `WHERE state = 'ga'` will not match `'GA'` |
| Primary / foreign keys | Enforced | Must be `NONCLUSTERED ... NOT ENFORCED`; duplicates are not rejected | Duplicate detection has to be done in data-quality checks |
| Loading CSV text into `DATE` | Implicit conversion | Rejected by the copy command | Required a VARCHAR staging layer plus `TRY_CAST` |
| Unsupported table types | n/a | `DATETIME`, `NVARCHAR`, `MONEY`, `TINYINT`, `XML`, others | Not hit here (schema used `INT`, `VARCHAR`, `DATE`, `DECIMAL`), but checked before creating tables |
| `TRY_CAST` on empty strings | `''` → `1900-01-01` / `0` | Same behavior | Guarded with `NULLIF(col, '')` |

## Takeaway

Queries and DDL written for SQL Server mostly carry over, but they can fail outright (case-sensitive names) or, worse, behave differently without an error (case-sensitive comparisons, unenforced keys). Migrated code should be tested, not assumed to work.
