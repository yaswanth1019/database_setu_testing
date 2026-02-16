For `machine_focas` and `machine_energy` (Low Velocity Data), the architectural requirements are completely different from `machine_cycles`.

**Recommendation:**
*   **Chunk Time Interval:** `1 month` (or `3 months`)
*   **Space Partitioning:** **NO** (Strictly forbidden for this volume)

Here is the detailed reasoning and configuration.

### 1. Why 7 Days is WRONG for these tables
If you use a 7-day chunk size for tables that only get 3-6 rows per machine per day, you will create **"Micro-Chunks."**

*   **The Math:**
    *   Assume 100 machines.
    *   `machine_focas`: 300 rows/day → 2,100 rows/week.
    *   2,100 rows is tiny (approx 100KB - 200KB).
*   **The Problem:**
    *   TimescaleDB (and PostgreSQL) has overhead for every single chunk (metadata, file handles, vacuum processes).
    *   Creating a separate physical file for just 200KB of data is inefficient. It wastes disk inodes and slows down the query planner (it has to scan through hundreds of tiny files instead of a few large ones).

### 2. The Recommended Strategy: Coarse Chunking

**For `machine_focas` and `machine_energy`:**
Use a **1 Month** interval.

This gathers enough data (~30 shifts per machine) into a single file to make Indexes effective and Compression efficient.

```sql
-- Create Hypertable for Focas (Low Velocity)
SELECT create_hypertable('silver.machine_focas', 'logical_date', 
    chunk_time_interval => INTERVAL '1 month');

-- Create Hypertable for Energy (Low Velocity)
SELECT create_hypertable('silver.machine_energy', 'logical_date', 
    chunk_time_interval => INTERVAL '1 month');
```

*(Note: If you have fewer than 50 machines, you could even increase this to `INTERVAL '3 months'` or `INTERVAL '1 year'`.)*

---

### 3. Compression is CRITICAL here
Since these tables are sparse (few rows per day), they are prime candidates for massive compression savings (often 96%+ reduction).

However, because the data is sparse, you must **Segment By** the Machine ID to force the database to group that machine's monthly history together physically.

**Configuration for `machine_focas`:**
```sql
ALTER TABLE silver.machine_focas SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'machine_iot_id', 
    timescaledb.compress_orderby = 'logical_date DESC'
);

-- Compress data older than 2 months (to allow for late shift data)
SELECT add_compression_policy('silver.machine_focas', INTERVAL '2 months');
```

**Configuration for `machine_energy`:**
```sql
ALTER TABLE silver.machine_energy SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'machine_iot_id, category', 
    timescaledb.compress_orderby = 'logical_date DESC'
);

-- Compress data older than 2 months
SELECT add_compression_policy('silver.machine_energy', INTERVAL '2 months');
```

### Summary Comparison

| Table | Frequency | Recommended Chunk Size | Why? |
| :--- | :--- | :--- | :--- |
| `machine_cycles` | High (Secs to Hours) | **7 Days** | Needs to manage high insert volume and keep recent data hot. |
| `machine_focas` | Low (3 per day) | **1 Month** | Avoids "micro-chunks"; groups enough data to compress well. |
| `machine_energy`| Low (6 per day) | **1 Month** | Avoids "micro-chunks"; groups enough data to compress well. |