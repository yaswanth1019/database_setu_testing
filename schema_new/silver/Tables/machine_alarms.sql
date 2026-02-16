--
-- PostgreSQL database dump
--

--
-- Name: machine_alarms; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_alarms (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    alarm_no integer,
    alarm_desc text,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_alarms_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_alarms_logical_date_idx ON silver.machine_alarms USING btree (logical_date DESC);

--
-- Name: machine_alarms fk_ma_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_alarms
    ADD CONSTRAINT fk_ma_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_alarms fk_ma_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_alarms
    ADD CONSTRAINT fk_ma_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--

--
-- Hypertable & Compression Configuration
--

-- Convert to Hypertable (1-month chunks for Low Frequency)
SELECT create_hypertable(relation => 'silver.machine_alarms'::regclass, time_column_name => 'logical_date'::name, chunk_time_interval => INTERVAL '1 month', if_not_exists => TRUE);

-- Enable Compression
ALTER TABLE silver.machine_alarms SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id',
    timescaledb.compress_orderby = 'logical_date ASC'
);

-- Add Compression Policy (Compress after 3 months)
SELECT add_compression_policy(relation => 'silver.machine_alarms'::regclass, compress_after => INTERVAL '3 months');

