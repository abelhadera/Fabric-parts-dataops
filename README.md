# fabric-parts-dataops

An end-to-end data pipeline on **Microsoft Fabric**: load CSVs, convert types, validate the data, and fail loudly when something is wrong.

## Architecture

```
CSV files ──► Lakehouse (raw files)
          ──► Warehouse stg.*   (all VARCHAR)       5 copy activities
          ──► Warehouse dbo.*   (typed tables)      usp_load_from_staging
          ──► dbo.dq_log        (quality results)   usp_run_dq_checks
```

![Pipeline](docs/screenshots/04-pipeline.png)

## Key decisions

- **Staging layer.** CSVs carry no types, so loading straight into `DATE` columns failed. Data lands as text, then `TRY_CAST` converts it in SQL. `NULLIF(col, '')` runs first, because `TRY_CAST('' AS DATE)` returns `1900-01-01`, not NULL.
- **Data-quality checks.** Fabric primary keys are `NOT ENFORCED`, so duplicates aren't blocked. After every load, checks write to `dq_log`. CRITICAL issues (duplicates, bad keys) fail the pipeline; WARNINGs (orphans, negative stock) are logged only.
- **Rerun-safe loads.** Both layers truncate before loading, so a rerun replaces data instead of duplicating it.
- **UTC timestamps.** Stored in UTC, converted for display.
- **Cost.** Smallest capacity (F2), paused when idle, with a $10 budget alert.

## Incident: duplicate load on rerun

A deliberate rerun tripled every table, because both layers appended instead of replacing. The checks caught it and failed the run. Fixed with truncate-and-reload at both layers. [Full write-up](docs/incident-001-duplicate-load.md)

![Data-quality failure](docs/screenshots/07-dq-failure.png)

## Run history

Early config failures, the deliberate failure, two clean reruns after the fix, and a scheduled run.

![Run history](docs/screenshots/11-scheduled-run.png)

## Source control

The Fabric workspace is connected to this repo on the `fabric-workspace` branch. Pipeline and warehouse definitions (tables, procedures) live in `fabric/` and reach `main` through pull requests.

![Pull request](docs/screenshots/14-pull-request.png)

## Repo layout

```
fabric/   workspace definitions, synced by Fabric Git integration
sql/      table, procedure, and validation scripts (run in order)
docs/     incident write-up, troubleshooting log, SQL Server vs Fabric notes, screenshots
data/     source CSVs
```
