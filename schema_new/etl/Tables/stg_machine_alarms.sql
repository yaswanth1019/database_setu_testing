--

CREATE UNLOGGED TABLE etl.stg_machine_alarms (
    raw_id BIGINT NOT NULL,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    alarm_no integer,
    alarm_desc text
);

--
-- PostgreSQL database dump complete
--

