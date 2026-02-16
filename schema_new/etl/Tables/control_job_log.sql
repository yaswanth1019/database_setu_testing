--
-- Name: control_job_log; Type: TABLE; Schema: etl; Owner: -
--

CREATE TABLE etl.control_job_log (
    log_id SERIAL PRIMARY KEY,
    job_name TEXT,
    start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_time TIMESTAMP WITH TIME ZONE,
    status TEXT,                        -- RUNNING, SUCCESS, FAILED
    rows_affected INT,
    message TEXT,
    execution_type TEXT                 -- 'INCREMENTAL' or 'REPROCESS'
);
