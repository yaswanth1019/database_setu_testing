--


CREATE UNLOGGED TABLE etl.stg_machine_status (
    raw_id BIGINT NOT NULL,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    program_no varchar(50),
    status varchar(50),
    operator_id varchar(50),
    target integer
);


--
-- PostgreSQL database dump complete
--
