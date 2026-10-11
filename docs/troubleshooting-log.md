# Troubleshooting log

Every issue hit while building the project, in order.

## Setup

**1. Fabric trial unavailable**
- **Symptom:** "A Fabric trial isn't available for your account." The Power BI trial activated; the Fabric trial did not.
- **Cause:** Microsoft does not offer Fabric trial capacities to newly created tenants.
- **Fix:** Provisioned a paid F2 capacity in Azure, paused when idle, with a $10 budget alert.

**2. "Unsupported account" when creating the capacity**
- **Symptom:** "You cannot create a Microsoft capacity using a personal account."
- **Cause:** Signed in to Azure with a personal Microsoft account (Outlook).
- **Fix:** Granted the tenant's organizational user the **Contributor** role on the subscription (least privilege that allows creating resources), then created the capacity signed in as that user.

**3. Capacity not created on first attempt**
- **Symptom:** Resource group existed but was empty; no deployment recorded.
- **Cause:** The Create click did not submit (the review page had reset).
- **Fix:** Recreated, waited on the deployment page until "Deployment succeeded." Also caught that the form defaulted to **F64**; changed to **F2** before creating.

## Warehouse

**4. Primary key failed: "Column name 'part_id' does not exist"**
- **Cause:** Typos in hand-written DDL (`parts_id`, `order_items_id`). Fabric names are case- and spelling-exact.
- **Fix:** Dropped and recreated the empty tables; verified every column against the source schema with `INFORMATION_SCHEMA.COLUMNS`.

**5. "Invalid object name 'information_schema.columns'"**
- **Cause:** Fabric Warehouse uses a case-sensitive collation, including for system views.
- **Fix:** `INFORMATION_SCHEMA.COLUMNS`. Logged in `sqlserver-vs-fabric.md`.

## Pipeline

**6. `MappingColumnNameNotFoundInSourceFile`**
- **Symptom:** Four of five copy activities failed: column `customer_id` not found in `suppliers.csv`.
- **Cause:** Activities were duplicated from `copy_customers`; changing the source file did not update the copied column mapping.
- **Fix:** For each duplicated activity: Mapping → **Reset** → **Import schemas**.
- **Lesson:** Get one activity working end to end before cloning it.

**7. `DWCopyCommandOperationFailed`: DATE not compatible with UTF8**
- **Symptom:** `Column 'signup_date' of type 'DATE' is not compatible with external data type 'Parquet ... UTF8'`.
- **Cause:** CSVs have no types; the copy stages data as text and the Warehouse will not load text into `DATE`. The mapping UI does not allow setting source types for CSV, and type conversion settings did not resolve it.
- **Fix:** Redesigned as ELT: copy into all-`VARCHAR` staging tables, then convert with `TRY_CAST` in `dbo.usp_load_from_staging`.

**8. Staging copy still failed with the same DATE error**
- **Cause:** Hand-typed staging DDL declared some columns as `DATE`, `INT` and `FLOAT`, which defeats the purpose of staging.
- **Fix:** Recreated all staging columns as `VARCHAR(255)`. (Also a reminder that `FLOAT` should never hold money; use `DECIMAL`.)

**9. Potential silent bug avoided: `TRY_CAST('' AS DATE)` → `1900-01-01`**
- **Fix:** `NULLIF(col, '')` before every cast. Verified with a check that counts `1900-01-01` dates (expected 0).
