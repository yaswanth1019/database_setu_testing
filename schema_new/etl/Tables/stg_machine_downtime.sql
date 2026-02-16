--

CREATE UNLOGGED TABLE etl.stg_machine_downtime (
    raw_id BIGINT NOT NULL,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    down_start timestamp with time zone,
    down_end timestamp with time zone,
    program_no text,
    down_id integer,
    down_threshold integer
);

--
-- PostgreSQL database dump complete
--

