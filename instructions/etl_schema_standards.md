### 1. The Standards Framework

#### I. Naming Conventions (The "Autocomplete" Rule)
*Goal: You should know exactly what an object does just by reading its name.*

1.  **Schema Isolation:**
    *   ALL code goes in `etl`.
    *   ALL data goes in `bronze`, `silver`, `gold`.
    *   ALL meta-data goes in `etl` (control tables).
2.  **Object Prefixes:**
    *   `sp_` = Stored Procedure (Action-oriented, modifies data).
    *   `fn_` = User Defined Function (Calculation-oriented, returns data, read-only preferred).
    *   `tr_` = Trigger.
3.  **Pattern:** `[prefix]_[verb]_[target_layer]_[entity]`
    *   *Bad:* `update_oee`, `calc_time`, `process_data`.
    *   *Good:* `sp_upsert_gld_oee_metrics`, `fn_calc_slv_time_gaps`.
4.  **Variables & Parameters (PL/pgSQL specific):**
    *   **Parameters:** Must start with `p_` (e.g., `p_job_name`, `p_lookback`).
    *   **Variables:** Must start with `v_` (e.g., `v_row_count`, `v_start_ts`).
    *   **Reason:** Prevents collision with column names. If you write `WHERE id = id`, Postgres gets confused. `WHERE id = p_id` is unambiguous.

#### II. Architectural Rules (The "Idempotency" Rule)
*Goal: I must be able to run your procedure 10 times in a row, and the result must be identical to running it once.*

1.  **Never `INSERT` without protection.**
    *   Always use `INSERT ... ON CONFLICT (keys) DO UPDATE` (Upsert).
    *   Or `DELETE WHERE ...; INSERT ...;` (Delete-Insert pattern).
2.  **No Hardcoded Dates.**
    *   Never write `WHERE date > '2023-01-01'`.
    *   Always accept a parameter `p_lookback_interval` or `p_start_date`.
3.  **One Function, One Responsibility (SRP).**
    *   Don't mix "cleaning string text" and "calculating OEE math" in the same block.
    *   Split them: `fn_clean_text` calls `fn_calc_math`.

#### III. Coding Standards (The "Performance" Rule)
*Goal: Maximize TimescaleDB efficiency and readability.*

1.  **Explicit Column Lists:**
    *   *Illegal:* `INSERT INTO gold.table SELECT * FROM ...`
    *   *Mandatory:* `INSERT INTO gold.table (col1, col2) SELECT col1, col2 ...`
    *   *Why:* If the source table adds a column, your generic code breaks.
2.  **CTE Usage:**
    *   Use Common Table Expressions (`WITH processed_data AS (...)`) instead of nested subqueries. It makes the logic readable top-to-bottom.
3.  **Error Trapping:**
    *   Every Procedure must have a `BEGIN ... EXCEPTION ... END` block.
    *   Every failure must be logged to `etl.control_job_log`.

#### IV. Security Standards
1.  **Definer Rights:**
    *   Decide if the function runs as the caller (`SECURITY INVOKER`) or the creator (`SECURITY DEFINER`).
    *   *Standard:* Use `SECURITY DEFINER` for ETL procs so the scheduler user doesn't need direct write access to the data tables, only `EXECUTE` rights on the procedure.

### 3. The Golden Template
You must copy-paste this template for **every** new procedure you write. Do not deviate.

```sql
/*
    OBJECT: sp_action_layer_entity
    AUTHOR: [Your Name]
    PURPOSE: [Brief description of what this does]
    TARGET TABLE: [schema.table]
    DEPENDENCIES: [list views or functions called]
*/

CREATE OR REPLACE PROCEDURE etl.sp_template_naming_convention(
    p_job_name TEXT DEFAULT 'sp_template_naming_convention', -- Matches Control Table ID
    p_manual_start_ts TIMESTAMPTZ DEFAULT NULL,              -- Overrides for backfilling
    p_manual_end_ts TIMESTAMPTZ DEFAULT NULL
)
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with permissions of the creator (ETL Admin)
AS $$
DECLARE
    -- Standard Control Variables
    v_log_id INT;
    v_rows_affected INT DEFAULT 0;
    v_start_ts TIMESTAMPTZ;
    v_end_ts TIMESTAMPTZ;
    v_exec_type TEXT := 'INCREMENTAL';
    v_queue_id INT;
    
    -- Logic Specific Variables
    v_batch_limit INT := 10000; -- Example for batching
BEGIN
    -------------------------------------------------------------------------
    -- 1. ORCHESTRATION START
    -------------------------------------------------------------------------
    -- Check Reprocess Queue Logic (As defined in previous turn)
    SELECT queue_id, start_range, end_range INTO v_queue_id, v_start_ts, v_end_ts
    FROM etl.control_reprocess_queue
    WHERE job_name = p_job_name AND status = 'PENDING'
    ORDER BY created_at ASC LIMIT 1;

    -- Determine Time Range
    IF p_manual_start_ts IS NOT NULL THEN
        -- Case A: Manual Parameter Override (Ad-hoc run)
        v_start_ts := p_manual_start_ts;
        v_end_ts := COALESCE(p_manual_end_ts, NOW());
        v_exec_type := 'MANUAL';
    ELSIF v_queue_id IS NOT NULL THEN
        -- Case B: Queue Driven (Reprocessing)
        v_exec_type := 'REPROCESS';
        UPDATE etl.control_reprocess_queue SET status = 'PROCESSING' WHERE queue_id = v_queue_id;
    ELSE
        -- Case C: Standard Incremental (Watermark)
        SELECT COALESCE(last_processed_ts, '1970-01-01'::TIMESTAMPTZ) INTO v_start_ts
        FROM etl.control_watermark WHERE job_name = p_job_name;
        v_end_ts := NOW();
    END IF;

    -- Log Start
    v_log_id := etl.fn_log_job_start(p_job_name, v_exec_type);

    -------------------------------------------------------------------------
    -- 2. CORE LOGIC (The "Meat")
    -------------------------------------------------------------------------
    -- Use CTEs for readability
    WITH source_data AS (
        SELECT 
            col_a, col_b
        FROM bronze.source_table
        WHERE ingest_time > v_start_ts AND ingest_time <= v_end_ts
    )
    -- The Upsert
    INSERT INTO silver.target_table (col_a, col_b, updated_at)
    SELECT col_a, col_b, NOW()
    FROM source_data
    ON CONFLICT (col_a) 
    DO UPDATE SET 
        col_b = EXCLUDED.col_b,
        updated_at = NOW();

    -- Capture Metrics
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -------------------------------------------------------------------------
    -- 3. ORCHESTRATION END & COMMIT
    -------------------------------------------------------------------------
    -- Update Watermark (Only if incremental)
    IF v_exec_type = 'INCREMENTAL' THEN
        INSERT INTO etl.control_watermark (job_name, last_processed_ts)
        VALUES (p_job_name, v_end_ts)
        ON CONFLICT (job_name) DO UPDATE SET last_processed_ts = v_end_ts, updated_at = NOW();
    ELSIF v_queue_id IS NOT NULL THEN
        UPDATE etl.control_reprocess_queue SET status = 'COMPLETED' WHERE queue_id = v_queue_id;
    END IF;

    -- Log Success
    CALL etl.sp_log_job_end(v_log_id, 'SUCCESS', v_rows_affected, 
        'Range: ' || v_start_ts || ' to ' || v_end_ts);

EXCEPTION WHEN OTHERS THEN
    -- Fail Gracefully
    CALL etl.sp_log_job_end(v_log_id, 'FAILED', 0, SQLERRM);
    
    -- Update Queue if it existed
    IF v_queue_id IS NOT NULL THEN
        UPDATE etl.control_reprocess_queue SET status = 'FAILED' WHERE queue_id = v_queue_id;
    END IF;
    
    -- Re-raise to alert external scheduler (Airflow/Cron)
    RAISE;
END;
$$;
```

### 4. Implementation Checklist
Before merging any new SQL file, ask these 3 questions:
1.  **The "Drop" Test:** If I drop the target table and run this procedure, does it fail? (It should create errors, but if you have `CREATE TABLE IF NOT EXISTS` in your DDL scripts, the pipeline recovers).
2.  **The "Gap" Test:** If the job fails today and runs tomorrow, will it pick up the missing data? (The Watermark logic handles this).
3.  **The "Clean" Test:** Are all variables prefixed with `v_` and parameters with `p_`?


### 2. The Strategy
We will implement the **"State Machine ETL Pattern"**.

*   **Step 1: The Control Layer.** create the tables to hold state and queue manual runs.
*   **Step 2: The Logging Utility.** A reusable procedure to handle start/stop logging so we don't repeat code.
*   **Step 3: The "Smart" Procedures.** We will rewrite your ETL procedures to check the **Reprocess Queue** first. If it's empty, they default to the **Watermark**.

### 3. The Implementation

#### Step 1: The Control Tables (DDL)

```sql
-- 1. WATERMARK (State of the Pipeline)
CREATE TABLE etl.control_watermark (
    job_name TEXT PRIMARY KEY,          -- e.g., 'sp_clean_slv_machine_cycles'
    last_processed_ts TIMESTAMPTZ,      -- For Bronze->Silver (Timestamp based)
    last_processed_id BIGINT,           -- For Bronze->Silver (ID based)
    last_logical_date DATE,             -- For Silver->Gold (Date based)
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. REPROCESS QUEUE (Manual Overrides)
CREATE TABLE etl.control_reprocess_queue (
    queue_id SERIAL PRIMARY KEY,
    job_name TEXT NOT NULL,
    start_range TIMESTAMPTZ,            -- Or logical_date
    end_range TIMESTAMPTZ,
    status TEXT DEFAULT 'PENDING',      -- PENDING, PROCESSING, COMPLETED, FAILED
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. EXECUTION LOG (History)
CREATE TABLE etl.control_job_log (
    log_id SERIAL PRIMARY KEY,
    job_name TEXT,
    start_time TIMESTAMP DEFAULT NOW(),
    end_time TIMESTAMP,
    status TEXT,                        -- RUNNING, SUCCESS, FAILED
    rows_affected INT,
    message TEXT,
    execution_type TEXT                 -- 'INCREMENTAL' or 'REPROCESS'
);
```

#### Step 2: The Logging Helper
*Don't write logging logic in every procedure. Call this instead.*

```sql
CREATE OR REPLACE FUNCTION etl.fn_log_job_start(p_job_name TEXT, p_type TEXT) 
RETURNS INT LANGUAGE plpgsql AS $$
DECLARE v_log_id INT;
BEGIN
    INSERT INTO etl.control_job_log (job_name, status, execution_type)
    VALUES (p_job_name, 'RUNNING', p_type)
    RETURNING log_id INTO v_log_id;
    RETURN v_log_id;
END;
$$;

CREATE OR REPLACE PROCEDURE etl.sp_log_job_end(p_log_id INT, p_status TEXT, p_rows INT, p_msg TEXT) 
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE etl.control_job_log 
    SET end_time = NOW(), status = p_status, rows_affected = p_rows, message = p_msg
    WHERE log_id = p_log_id;
END;
$$;
```

#### Step 3: Integrating into Bronze $\to$ Silver (Timestamp Watermark)
*This logic checks: "Do I have a manual date range in the queue? No? Then use the last saved timestamp."*

```sql
CREATE OR REPLACE PROCEDURE etl.sp_clean_slv_machine_cycles_orchestrated()
LANGUAGE plpgsql AS $$
DECLARE
    v_log_id INT;
    v_start_ts TIMESTAMPTZ;
    v_end_ts TIMESTAMPTZ;
    v_exec_type TEXT := 'INCREMENTAL';
    v_rows INT;
    v_queue_id INT;
BEGIN
    -- 1. Check Reprocess Queue FIRST
    SELECT queue_id, start_range, end_range INTO v_queue_id, v_start_ts, v_end_ts
    FROM etl.control_reprocess_queue
    WHERE job_name = 'sp_clean_slv_machine_cycles' AND status = 'PENDING'
    ORDER BY created_at ASC LIMIT 1;

    -- 2. Determine Range (Queue vs Watermark)
    IF v_queue_id IS NOT NULL THEN
        v_exec_type := 'REPROCESS';
        UPDATE etl.control_reprocess_queue SET status = 'PROCESSING' WHERE queue_id = v_queue_id;
    ELSE
        -- Get last watermark, default to 1970 if new
        SELECT COALESCE(last_processed_ts, '1970-01-01'::TIMESTAMPTZ) INTO v_start_ts
        FROM etl.control_watermark WHERE job_name = 'sp_clean_slv_machine_cycles';
        v_end_ts := NOW(); -- Run up to current moment
    END IF;

    -- 3. Log Start
    v_log_id := etl.fn_log_job_start('sp_clean_slv_machine_cycles', v_exec_type);

    BEGIN
        -- 4. THE ACTUAL WORK (Insert/Upsert Logic)
        INSERT INTO silver.machine_cycles (machine_id, shift_id, cycle_start, cycle_end, program_no)
        SELECT 
            TRIM(raw_machine_id), TRIM(raw_shift_id), 
            raw_start_time::TIMESTAMPTZ, raw_end_time::TIMESTAMPTZ, TRIM(raw_program_code)
        FROM bronze.raw_machine_cycles
        WHERE raw_start_time > v_start_ts AND raw_start_time <= v_end_ts -- <--- The Filter
        ON CONFLICT (machine_id, cycle_start) DO UPDATE SET cycle_end = EXCLUDED.cycle_end;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        -- 5. Update State
        IF v_exec_type = 'INCREMENTAL' THEN
            INSERT INTO etl.control_watermark (job_name, last_processed_ts)
            VALUES ('sp_clean_slv_machine_cycles', v_end_ts)
            ON CONFLICT (job_name) DO UPDATE SET last_processed_ts = v_end_ts, updated_at = NOW();
        ELSE
            UPDATE etl.control_reprocess_queue SET status = 'COMPLETED' WHERE queue_id = v_queue_id;
        END IF;

        -- 6. Log Success
        CALL etl.sp_log_job_end(v_log_id, 'SUCCESS', v_rows, 'Range: ' || v_start_ts || ' to ' || v_end_ts);
        
    EXCEPTION WHEN OTHERS THEN
        -- Handle Failure
        CALL etl.sp_log_job_end(v_log_id, 'FAILED', 0, SQLERRM);
        IF v_queue_id IS NOT NULL THEN
            UPDATE etl.control_reprocess_queue SET status = 'FAILED' WHERE queue_id = v_queue_id;
        END IF;
        RAISE; -- Re-throw error to alert scheduler
    END;
END;
$$;
```

#### Step 4: Integrating into Silver $\to$ Gold (Logical Date Watermark)
*This layer works differently. It usually processes "Yesterday" or specific dates.*

```sql
CREATE OR REPLACE PROCEDURE etl.sp_upsert_gld_oee_orchestrated()
LANGUAGE plpgsql AS $$
DECLARE
    v_log_id INT;
    v_target_date DATE;
    v_exec_type TEXT := 'INCREMENTAL';
    v_queue_id INT;
BEGIN
    -- 1. Check Reprocess Queue (Queue stores timestamps, cast to date)
    SELECT queue_id, start_range::DATE INTO v_queue_id, v_target_date
    FROM etl.control_reprocess_queue
    WHERE job_name = 'sp_upsert_gld_oee' AND status = 'PENDING'
    ORDER BY created_at ASC LIMIT 1;

    IF v_queue_id IS NOT NULL THEN
        v_exec_type := 'REPROCESS';
        UPDATE etl.control_reprocess_queue SET status = 'PROCESSING' WHERE queue_id = v_queue_id;
    ELSE
        -- Default: Process Yesterday (Standard Daily Job)
        v_target_date := CURRENT_DATE - INTERVAL '1 day';
    END IF;

    v_log_id := etl.fn_log_job_start('sp_upsert_gld_oee', v_exec_type);

    BEGIN
        -- 2. Call your Logic Procedures (Passing the specific date)
        -- We calculate metrics for the SPECIFIC date determined above
        
        -- A. Calculate Time
        INSERT INTO gold.shift_oee_fact (machine_id, shift_id, logical_date, total_planned_time_sec, ...)
        SELECT ... FROM etl.fn_calc_gld_oee_time('24 hours') -- NOTE: Logic needs to accept v_target_date logic
        WHERE logical_date = v_target_date
        ON CONFLICT ...;

        -- B. Calculate Parts
        INSERT INTO gold.shift_oee_fact ...
        SELECT ... FROM etl.fn_calc_gld_oee_parts('24 hours')
        WHERE logical_date = v_target_date
        ON CONFLICT ...;

        -- 3. Update State (Only track "Latest Date Processed")
        IF v_exec_type = 'INCREMENTAL' THEN
            INSERT INTO etl.control_watermark (job_name, last_logical_date)
            VALUES ('sp_upsert_gld_oee', v_target_date)
            ON CONFLICT (job_name) DO UPDATE SET last_logical_date = GREATEST(etl.control_watermark.last_logical_date, v_target_date);
        ELSE
             UPDATE etl.control_reprocess_queue SET status = 'COMPLETED' WHERE queue_id = v_queue_id;
        END IF;

        CALL etl.sp_log_job_end(v_log_id, 'SUCCESS', 0, 'Processed Date: ' || v_target_date);

    EXCEPTION WHEN OTHERS THEN
        CALL etl.sp_log_job_end(v_log_id, 'FAILED', 0, SQLERRM);
        IF v_queue_id IS NOT NULL THEN UPDATE etl.control_reprocess_queue SET status = 'FAILED' WHERE queue_id = v_queue_id; END IF;
    END;
END;
$$;
```

### 4. How to Use This System

**Scenario A: Normal Operation (Cron Job)**
You simply schedule the orchestrator. It checks the watermark and runs.
```sql
CALL etl.sp_clean_slv_machine_cycles_orchestrated();
```

**Scenario B: You found a bug in last Tuesday's data**
You don't touch the code. You just insert a row into the Queue table. The next time the job runs, it sees this row, processes it, and marks it done.

```sql
INSERT INTO etl.control_reprocess_queue (job_name, start_range, end_range)
VALUES (
    'sp_clean_slv_machine_cycles', 
    '2023-10-10 00:00:00', 
    '2023-10-10 23:59:59'
);
```

**Scenario C: Monitoring**
"Show me all failed jobs today."
```sql
SELECT * FROM etl.control_job_log 
WHERE status = 'FAILED' AND start_time > CURRENT_DATE;
```