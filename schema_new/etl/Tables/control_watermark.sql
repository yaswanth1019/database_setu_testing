--
-- Name: control_watermark; Type: TABLE; Schema: etl; Owner: -
--

CREATE TABLE etl.control_watermark (
    job_name TEXT PRIMARY KEY,          -- e.g., 'sp_clean_slv_machine_cycles'
    last_processed_ts TIMESTAMPTZ,      -- For Bronze->Silver (Timestamp based)
    last_processed_id BIGINT,           -- For Bronze->Silver (ID based)
    last_logical_date DATE,             -- For Silver->Gold (Date based)
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
