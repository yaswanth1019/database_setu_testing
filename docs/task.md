# Project Tasks

This file tracks the ongoing tasks and progress of the SETU_2 project migrations and schema updates.

## Current Focus
- [x] Remove pg_dump session-level SET commands from `schema_new`
- [x] Implement silver layer schema changes (Hypertable & Compression)
- [x] Standardize TimescaleDB function calls (Named Parameters & Type Casts)
- [ ] Sync Bronze and Silver layers (logical_date, shift_id/name)
- [x] Convert `VARCHAR` columns to `TEXT` across all tables




## Completed Tasks
- [x] Cleaned up `schema_new` SQL files (removed pg_dump artifacts)
- [x] Established persistent task tracking in `docs/task.md`

## SQL Standards (TimescaleDB)
1. **Fully Named Parameters**: Always use named parameters for extension functions (e.g., `relation => '...'`).
2. **Type Casting**: Always cast relation strings to `::regclass` and time column strings to `::name`.
3. **Compression/Retention**: Use explicit intervals and named parameters for policy functions.
4. **Prefer TEXT over VARCHAR**: Use `TEXT` for all character data to avoid arbitrary length limits and future migrations.


## Architecture Decisions
Refer to [ArchitecturalDecisionRecords.md](file:///d:/SETU_2/docs/ArchitecturalDecisionRecords.md) for detailed technical decisions.

