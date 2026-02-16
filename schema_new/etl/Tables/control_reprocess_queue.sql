--
-- Name: control_reprocess_queue; Type: TABLE; Schema: etl; Owner: -
--

CREATE TABLE etl.control_reprocess_queue (
    queue_id SERIAL PRIMARY KEY,
    job_name TEXT NOT NULL,
    start_range TIMESTAMPTZ,            -- Or logical_date
    end_range TIMESTAMPTZ,
    status TEXT DEFAULT 'PENDING',      -- PENDING, PROCESSING, COMPLETED, FAILED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
