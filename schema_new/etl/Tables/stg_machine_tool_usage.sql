--


CREATE UNLOGGED TABLE etl.stg_machine_tool_usage (
    raw_id BIGINT NOT NULL,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    tool_no varchar(50) NOT NULL,
    target_count integer,
    actual_count integer
);


--
-- PostgreSQL database dump complete
--
