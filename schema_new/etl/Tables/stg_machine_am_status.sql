--

CREATE UNLOGGED TABLE etl.stg_machine_am_status (
    raw_id BIGINT NOT NULL,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    shift_id integer,
    cnctimestamp timestamp with time zone,
    status text,
    am_corrected_count integer,
    am_pending_count integer
);

--
-- PostgreSQL database dump complete
--

