--
-- PostgreSQL database dump
--

--
-- Name: machine_focas_program_production; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_focas_program_production (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    program_no text,
    actual_count integer,
    target_count integer,
    std_load_unload integer,
    std_cycle_time integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_focas_program_production_logical_date_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_focas_program_production_logical_date_idx ON silver.machine_focas_program_production USING btree (logical_date DESC);

--
-- Name: machine_focas_program_production fk_mfpp_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_focas_program_production
    ADD CONSTRAINT fk_mfpp_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_focas_program_production fk_mfpp_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_focas_program_production
    ADD CONSTRAINT fk_mfpp_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--

--
-- Hypertable & Compression Configuration
--

-- Convert to Hypertable (1-month chunks for Low Frequency)
SELECT create_hypertable(relation => 'silver.machine_focas_program_production'::regclass, time_column_name => 'logical_date'::name, chunk_time_interval => INTERVAL '1 month', if_not_exists => TRUE);

-- Enable Compression
ALTER TABLE silver.machine_focas_program_production SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id, program_no',
    timescaledb.compress_orderby = 'logical_date ASC'
);

-- Add Compression Policy (Compress after 3 months)
SELECT add_compression_policy(relation => 'silver.machine_focas_program_production'::regclass, compress_after => INTERVAL '3 months');

