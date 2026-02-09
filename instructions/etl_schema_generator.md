# DIRECTIVE: ETL STAGING LAYER GENERATION (SETU_2)

**Role:** Senior Data Engineer.
**Objective:** Generate an ETL Staging table (UNLOGGED) for every Bronze (Raw) table.

### 1. THE REPLICATION RULES (MANDATORY)
For every **Bronze Table** in `bronze.*`, generate a corresponding **ETL Table** using these rules:
1.  **Table Naming:** Prefix the table with `etl.stg_` (e.g., `bronze.raw_machine_status` becomes `etl.stg_machine_status`).
2.  **Performance Optimization:** Use the `UNLOGGED` keyword in the `CREATE TABLE` statement to maximize performance by disabling WAL logging.
3.  **Column Transformation:**
    *   **Rename**: Change the `id` column from Bronze to `raw_id` (BIGINT) in ETL.
    *   **Remove**: `ingested_at` and `kafka_offset` (these are partition/audit metadata not needed for the transformation stage).
    *   **Keep**: All other business telemetry columns (e.g., `device_iot_id`, `machine_iot_id`, `cnctimestamp`, etc.).
4.  **No Hypertable**: ETL tables are high-speed flight zones. Do **NOT** use `create_hypertable` or retention policies.

### 2. SQL TEMPLATE
```sql
--
-- Name: stg_[TABLE_NAME]; Type: TABLE; Schema: etl; Owner: -
--

CREATE UNLOGGED TABLE etl.stg_[TABLE_NAME] (
    raw_id BIGINT,
    device_iot_id INTEGER NOT NULL,
    machine_iot_id INTEGER NOT NULL,
    [BUSINESS_COLUMNS...]
);
```

### 3. RATIONALE
- **UNLOGGED**: Since staging tables are temporary and can be rebuilt from Bronze if the database crashes, we sacrifice Durability for 3x Ingest Speed.
- **raw_id**: This allows us to join back to the Bronze layer for auditing or error correction during the transformation process.
