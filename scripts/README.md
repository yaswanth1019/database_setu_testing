# ETL Staging Generation Script

This script automates the creation of the **ETL Layer (Staging)** from the **Bronze Layer (Raw)**.

## What it does
- Reads all `raw_*.sql` files from `schema_new/bronze/Tables/`.
- Creates corresponding `stg_*.sql` files in `schema_new/etl/Tables/`.
- **Performance**: Adds the `UNLOGGED` keyword to all staging tables to maximize ingestion speed.
- **Traceability**: Replaces the Bronze identity `id` with a `raw_id` column to maintain a link back to the raw source.
- **Cleanup**: Removes system metadata columns (`ingested_at`, `kafka_offset`) that are not required during the staging transformation phase.

## When to run it
Run this script whenever:
1.  **A new table is added** to the Bronze layer.
2.  **The schema changes** in the Bronze layer (e.g., adding a new telemetry column).
3.  **The ETL schema needs to be reset** or re-synchronized with the Raw layer.

## How to run it
Ensure you are in the project root directory and run:
```powershell
python ./scripts/generate_etl_tables.py
```

## Maintenance
The script uses environment variables for directory paths. Ensure you have a `.env` file in the project root with the following variables:
- `BRONZE_DIR`: Path to your Bronze tables.
- `ETL_DIR`: Path to your ETL staging tables.

Example `.env`:
```
BRONZE_DIR=d:\SETU_2\schema_new\bronze\Tables
ETL_DIR=d:\SETU_2\schema_new\etl\Tables
```

See `.env.example` for a template.
