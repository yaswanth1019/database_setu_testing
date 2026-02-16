--

CREATE UNLOGGED TABLE etl.stg_machine_focas (
    raw_id BIGINT NOT NULL,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    shift_id integer,
    cnctimestamp timestamp with time zone,
    part_count integer,
    rej_count integer,
    pot integer,
    ot integer,
    ct integer
);

--
-- PostgreSQL database dump complete
--

