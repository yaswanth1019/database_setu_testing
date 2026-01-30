- **Version**: 2.0.0
- **Created**: January 30, 2026
- **Updated**: January 30, 2026
- **Author**: Amith B R
- **Description**: Records significant architectural decisions for the SETU project (MVP2).
- **Status**: Live

# Architectural Decision Records (ADR) - MVP2

---

## 1. Schema Normalization (MVP2)

*   **Context**: The legacy schema used mixed GUIDs/Strings for IDs and had tight coupling between Machines and Plants, making re-assignment difficult.
*   **Decision**: 
    1.  **Integer IDs**: Adopt `SERIAL` (Integer) Primary Keys for all Master tables (`companies`, `plants`, `machines`).
    2.  **Decoupling**: Remove `plant_id` from `machine_info`. Use `plant_machine_mapping` table for N:M flexibility (though likely 1:1 in practice).
    3.  **Device Separation**: Split `device_id` into a separate `device_info` table to manage hardware inventory independently of machine assignment.
    4.  **Global Downtime Codes**: Remove `company_id` from `downtime_codes` to enforce a standard global catalog.
*   **Rationale**: 
    *   **Performance**: joining on INT is faster than Text/GUID.
    *   **Flexibility**: Machines can be moved between plants without changing their core record.
    *   **Inventory**: Hardware lifecycle (Devices) is distinct from Asset lifecycle (Machines).


---

## 2. Bronze Layer Architecture (MVP2)

*   **Context**: The previous `raw_telemetry` (single JSONB table) design suffered from poor debuggability and difficulty in managing retention for specific data types.
*   **Decision**: Adopt a "Staging Table" approach with strict schemas for the Bronze Layer.
    1.  **Strict Schemas**: Replace generic JSONB with specific tables (`stg_machine_cycles`, etc.) that mirror Silver facts.
    2.  **Partitioning**: Partition Hypertables by `ingested_at` (Arrival Time), NOT event time.
    3.  **Chunking**: Use **1-day chunks**.
    4.  **Retention**: **30 days**.
*   **Standards**:
    *   **Prefix**: `bronze.stg_`.
    *   **System Columns**: `id` (Identity), `ingested_at`, `kafka_offset`, `machine_iot_id`, `device_iot_id`.

*   **Rationale (The Warehouse Analogy)**:
    *   **Bronze is a warehouse receiving boxes**. Every day, trucks drop off boxes. Some contain today's items, some contain last week's.
    *   **Ingestion Partitioning Rule**: *"Sort boxes by arrival date, not manufacture date."*
        *   When boxes arrive, label them by the day they entered. You don't control when trucks arrive, and old items can arrive today.
        *   We care about when we *received* the data for cleanup purposes.
    *   **Chunk Management Rule**: *"Use small daily storage bins."*
        *   Store boxes in daily bins. When it's time to clean up, you throw away one bin at a time.
        *   This makes `DROP_CHUNK` fast and keeps the warehouse running smoothly while new trucks arrive.
    *   **The "Watermark Anchor"**:
        *   We force an `id BIGINT IDENTITY` column on every Bronze table.
        *   This acts as the absolute tie-breaker. If 1,000 machines report events at the exact same millisecond, the `id` allows the ETL process to know exactly where to restart (`WHERE id > last_processed_id`) without losing or duplicating data.
