--


CREATE UNLOGGED TABLE etl.stg_machine_pm_status (
    raw_id BIGINT NOT NULL,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    cnctimestamp timestamp with time zone,
    status varchar(50),
    pm_corrected_count integer,
    pm_pending_count integer
);


--
-- PostgreSQL database dump complete
--
