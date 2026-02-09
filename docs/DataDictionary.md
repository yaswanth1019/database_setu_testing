# SETU Data Dictionary (v2.0.0)

- **Version**: 2.0.0
- **Status**: **Active Development (Standardized Surrogate Keys)**
- **Created**: January 6, 2026
- **Last Updated**: February 4, 2026
- **Architecture**: TimescaleDB (PostgreSQL)
- **Primary Source**: `schema_new/` folder (standardized schema)

---

## 1. Executive Summary

This document serves as the **Single Source of Truth** for the SETU Data Platform. It reflects the recent standardization of the schema, moving towards `iot_id` surrogate keys, standardizing time columns to `logical_date` in Silver, and implementing a 30-day retention Bronze (Raw) layer for high-scale scalability.

### Core Architectural Principles
> [!IMPORTANT]
> **Surrogate Keys**: The schema now uses `iot_id` (Integer) as the primary link between hardware (`master.device_info`), machines (`master.machine_info`), and companies (`master.companies`).
> 
> **Write-Time Shift Resolution**: Shifts are resolved during the Bronze to Silver ingestion and stored as integers (`shift_id`) in all Silver tables to ensure high-performance dashboard aggregations without complex run-time joins.
>
> **Logical Dates**: Silver tables use `logical_date` (TIMESTAMPTZ) to represent the business date of the event, decoupled from the ingestion timestamp `ingested_at` found in Bronze.

---

## 2. Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    %% Master Schema (Dimensions)
    COMPANIES ||--o{ PLANTS : "owns"
    COMPANIES ||--o{ USERS : "authenticates"
    COMPANIES ||--o{ ALERT_RULES : "configures"
    
    PLANTS ||--o{ SHIFTS : "schedules"
    
    COMPANIES ||--o{ MACHINE_INFO : "owns"
    DEVICE_INFO ||--o1 MACHINE_INFO : "connected to"
    MACHINE_INFO ||--o{ PLANT_MACHINE_MAPPING : "mapped to"
    PLANTS ||--o{ PLANT_MACHINE_MAPPING : "contains"
    
    MACHINE_INFO ||--o{ MACHINE_ASSETS : "describes"
    MACHINE_INFO ||--o{ PRODUCTION_TARGETS : "targets"
    
    %% Silver Schema (Facts)
    MACHINE_INFO ||--o{ MACHINE_STATUS : "telemetry"
    MACHINE_INFO ||--o{ MACHINE_CYCLES : "telemetry"
    MACHINE_INFO ||--o{ MACHINE_ALARMS : "telemetry"
    MACHINE_INFO ||--o{ MACHINE_DOWNTIME : "telemetry"
    MACHINE_INFO ||--o{ MACHINE_ENERGY : "telemetry"
    MACHINE_INFO ||--o{ MACHINE_FOCAS : "telemetry"
    MACHINE_INFO ||--o{ MACHINE_TOOL_USAGE : "telemetry"
    MACHINE_INFO ||--o{ MACHINE_AM_STATUS : "telemetry"
    MACHINE_INFO ||--o{ MACHINE_PM_STATUS : "telemetry"
```

---

## 3. Layer Definitions

### 3.1. Bronze Layer (Raw Ingestion)
**Role**: High-velocity landing zone.
- **Retention**: 30 Days (TimescaleDB Drop Chunks).
- **Standards**: Every table includes `id` (BIGINT Identity), `ingested_at` (Partition Key), `kafka_offset`, `device_iot_id`, and `machine_iot_id`.

| Table | Matching Silver | Columns | Description |
|:---|:---|:---|:---|
| `bronze.raw_machine_status` | `silver.machine_status` | `id`, `ingested_at`, `kafka_offset`, `device_iot_id`, `machine_iot_id`, `cnctimestamp`, `status` | Raw telemetry snapshot. |
| `bronze.raw_machine_cycles` | `silver.machine_cycles` | `id`, `ingested_at`, `kafka_offset`, `device_iot_id`, `machine_iot_id`, `cycle_start`, `cycle_end`, `program_no`, `std_load_unload`, `std_cycle_time` | Granular cycle records. |
| `bronze.raw_machine_am_status`| `silver.machine_am_status` | `id`, `ingested_at`, `kafka_offset`, `device_iot_id`, `machine_iot_id`, `logical_date`, `shift_id`, `cnctimestamp`, `status`, `am_corrected_count`, `am_pending_count` | Autonomous Maintenance logs. |
| `bronze.raw_machine_pm_status`| `silver.machine_pm_status` | `id`, `ingested_at`, `kafka_offset`, `device_iot_id`, `machine_iot_id`, `logical_date`, `cnctimestamp`, `status`, `pm_corrected_count`, `pm_pending_count` | Preventative Maintenance logs. |
| `bronze.raw_machine_focas_program_production` | `silver.machine_focas_program_production` | `id`, `ingested_at`, `kafka_offset`, `device_iot_id`, `machine_iot_id`, `logical_date`, `shift_id`, `program_no`, `actual_count`, `target_count`, `std_cycle_time`, `std_load_unload` | Multi-program production telemetry. |

### 3.2. Master Layer (Dimensions)
**Role**: Global reference data.

| Table | PK | Columns | Description |
|:---|:---|:---|:---|
| `master.companies` | `iot_id` | `iot_id` (PK), `company_id` (**Legacy**), `company_name`, `address`, `state`, `country`, `pin_code`, `email_id`, `phone_no`, `default_plant_id` | Multi-tenant root entity. |
| `master.plants` | `plant_id` | `plant_id` (PK), `company_iot_id` (FK), `plant_name`, `plant_city` | Industrial site registry. |
| `master.machine_info` | `iot_id` | `iot_id` (PK), `machine_id` (**Legacy**), `company_iot_id` (FK), `device_iot_id` (FK), `ip_address`, `port_no` | Unified machine asset record. |
| `master.device_info` | `device_iot_id` | `device_iot_id` (PK), `device_id` (**Legacy**), `description`, `is_assigned`, `created_by`, `updated_at` | Hardware registry. |
| `master.shifts` | `id` | `id` (PK), `company_iot_id` (FK), `shift_name`, `shift_id` (**Logic ID**), `is_running`, `from_day`, `to_day`, `from_time`, `to_time`, `updated_ts` | Dynamic scheduling logic. |
| `master.users` | `id` | `user_id` (**Legacy PK**), `company_iot_id` (**FK PK**), `user_no`, `full_name`, `role`, `plant_id` | RBAC and tenancy. |
| `master.machine_assets` | `composite` | `machine_iot_id` (FK), `company_iot_id` (FK), `supplier_name`, `model_number`, `manufacturing_year`, `commissioned_date`, `subscription_tier` | Asset metadata. |
| `master.plant_machine_mapping` | `mapping_id` | `mapping_id` (PK), `plant_id` (FK), `machine_iot_id` (FK) | Asset assignment to plants. |

### 3.3. Silver Layer (Normalized Facts)
**Role**: Analytical core. Partitioned by `logical_date`.
- **Standard**: All tables use `company_iot_id` and `machine_iot_id` for efficient filtering.

| Table | Timestamp | Columns | Purpose |
|:---|:---|:---|:---|
| `silver.machine_status` | `logical_date` | `logical_date`, `company_iot_id` (FK), `machine_iot_id` (FK), `shift_id`, `shift_name`, `program_no`, `status`, `operator_id`, `target` | Real-time state history. |
| `silver.machine_cycles` | `cycle_start` | `logical_date`, `company_iot_id` (FK), `machine_iot_id` (FK), `shift_id`, `shift_name`, `cycle_start`, `cycle_end`, `program_no`, `std_load_unload`, `std_cycle_time`, `actual_load_unload`, `actual_cycle_time` | Individual part production. |
| `silver.machine_downtime` | `down_start` | `logical_date`, `company_iot_id` (FK), `machine_iot_id` (FK), `shift_id`, `shift_name`, `down_start`, `down_end`, `program_no`, `down_id`, `down_threshold` | OEE Availability loss logs. |
| `silver.machine_energy` | `logical_date` | `logical_date`, `company_iot_id` (FK), `machine_iot_id` (FK), `shift_id`, `shift_name`, `category`, `servo_energy`, `spindle_energy`, `total_energy` | Resource consumption logs. |
| `silver.machine_am_status` | `logical_date` | `logical_date`, `company_iot_id` (FK), `machine_iot_id` (FK), `shift_id`, `shift_name`, `status`, `am_corrected_count`, `am_pending_count` | Autonomous Maintenance. |
| `silver.machine_pm_status` | `logical_date` | `logical_date`, `company_iot_id` (FK), `machine_iot_id` (FK), `status`, `pm_corrected_count`, `pm_pending_count` | Preventative Maintenance. |
| `silver.machine_focas_program_production` | `logical_date` | `logical_date`, `company_iot_id` (FK), `machine_iot_id` (FK), `shift_id`, `shift_name`, `program_no`, `actual_count`, `target_count`, `std_load_unload`, `std_cycle_time` | CNC program analytics. |
| `silver.machine_tool_usage` | `logical_date` | `logical_date`, `company_iot_id` (FK), `machine_iot_id` (FK), `shift_id`, `shift_name`, `tool_no`, `target_count`, `actual_count` | Resource consumption logs. |

### 3.4. Config Layer
**Role**: Operational settings and alert state configuration.

| Table/Proc | Layer | Columns | Description |
|:---|:---|:---|:---|
| `config.alert_rules` | Config | `rule_id` (PK), `rule_name`, `description`, `metric`, `condition_operator`, `threshold_value`, `severity`, `enabled`, `company_iot_id` | Global/Tenant rule config. |
| `config.alert_subscriptions`| Config | `subscription_id` (PK), `rule_id`, `user_id`, `method`, `target_address`, `company_iot_id` | Notification routing. |

- **Monitoring**: Real-time observability for high-frequency writes.

### 3.5. ETL Layer (Staging)
**Role**: Transient, high-speed flight zone for data enrichment.
- **Standards**: All tables are `UNLOGGED` and use `raw_id` to link to Bronze.

| Table | Source | Tracing | Purpose |
|:---|:---|:---|:---|
| `etl.stg_machine_status` | `bronze.raw_machine_status` | `raw_id` | Enriched machine state. |
| `etl.stg_machine_cycles` | `bronze.raw_machine_cycles` | `raw_id` | Cycle calculations. |
| `etl.stg_machine_alarms` | `bronze.raw_machine_alarms` | `raw_id` | Alarm buffering. |
| `etl.stg_machine_downtime`| `bronze.raw_machine_downtime`| `raw_id` | Downtime categorization. |

---

## 4. Business Logic (Procedures & Functions)

### Ingestion Logic
- **`etl.proc_ingest_payload()`** (Planned): The future "Traffic Warden" of the system. Will replace legacy `bronze.proc_ingest_payload` with standardized multi-layer routing.
