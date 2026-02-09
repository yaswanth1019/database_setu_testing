--


CREATE UNLOGGED TABLE etl.stg_machine_focas_program_production (
    raw_id BIGINT NOT NULL,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    shift_id integer,
    program_no varchar(50),
    actual_count integer,
    target_count integer,
    std_load_unload integer,
    std_cycle_time integer,
    cnctimestamp timestamp with time zone
);


--
-- PostgreSQL database dump complete
--
