--
-- PostgreSQL database dump
--

--
-- Name: machine_pm_status; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_pm_status (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    status text,
    pm_corrected_count integer,
    pm_pending_count integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_pm_status_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_pm_status_logical_date_idx ON silver.machine_pm_status USING btree (logical_date DESC);

--
-- Name: machine_pm_status fk_pm_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_pm_status
    ADD CONSTRAINT fk_pm_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_pm_status fk_pm_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_pm_status
    ADD CONSTRAINT fk_pm_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--

--
-- Hypertable & Compression Configuration
--

-- Convert to Hypertable (1-month chunks for Low Frequency)
SELECT create_hypertable(relation => 'silver.machine_pm_status'::regclass, time_column_name => 'logical_date'::name, chunk_time_interval => INTERVAL '1 month', if_not_exists => TRUE);

-- Enable Compression
ALTER TABLE silver.machine_pm_status SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id',
    timescaledb.compress_orderby = 'logical_date ASC'
);

-- Add Compression Policy (Compress after 3 months)
SELECT add_compression_policy(relation => 'silver.machine_pm_status'::regclass, compress_after => INTERVAL '3 months');

