--
-- PostgreSQL database dump
--

--
-- Name: machine_am_status; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_am_status (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    status text,
    am_corrected_count integer,
    am_pending_count integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_am_status_logical_date_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_am_status_logical_date_idx ON silver.machine_am_status USING btree (logical_date DESC);

--
-- Name: machine_am_status fk_am_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_am_status
    ADD CONSTRAINT fk_am_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_am_status fk_am_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_am_status
    ADD CONSTRAINT fk_am_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--

--
-- Hypertable & Compression Configuration
--

-- Convert to Hypertable (1-month chunks for Low Frequency)
SELECT create_hypertable(relation => 'silver.machine_am_status'::regclass, time_column_name => 'logical_date'::name, chunk_time_interval => INTERVAL '1 month', if_not_exists => TRUE);

-- Enable Compression
ALTER TABLE silver.machine_am_status SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id',
    timescaledb.compress_orderby = 'logical_date ASC'
);

-- Add Compression Policy (Compress after 3 months)
SELECT add_compression_policy(relation => 'silver.machine_am_status'::regclass, compress_after => INTERVAL '3 months');

