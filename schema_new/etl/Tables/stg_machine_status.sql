--

CREATE UNLOGGED TABLE etl.stg_machine_status (
    raw_id BIGINT NOT NULL,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    program_no text,
    status text,
    operator_id text,
    target integer
);

--
-- PostgreSQL database dump complete
--

