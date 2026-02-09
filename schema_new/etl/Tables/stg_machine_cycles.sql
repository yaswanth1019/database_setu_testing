--


CREATE UNLOGGED TABLE etl.stg_machine_cycles (
    raw_id BIGINT NOT NULL,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cycle_start timestamp with time zone,
    cycle_end timestamp with time zone,
    program_no varchar(50),
    std_load_unload integer,
    std_cycle_time integer,
    down_threshold integer
);


--
-- PostgreSQL database dump complete
--
