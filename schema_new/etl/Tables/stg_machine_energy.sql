--


CREATE UNLOGGED TABLE etl.stg_machine_energy (
    raw_id BIGINT NOT NULL,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    category varchar(50),
    servo_energy numeric(12,3),
    spindle_energy numeric(12,3),
    total_energy numeric(12,3)
);


--
-- PostgreSQL database dump complete
--
