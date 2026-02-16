--
-- PostgreSQL database dump
--

--
-- Name: machine_downtime; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_downtime (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    down_start timestamp with time zone,
    down_end timestamp with time zone,
    program_no text,
    down_id integer,
    down_threshold integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_downtime_down_start_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_downtime_down_start_idx ON silver.machine_downtime USING btree (down_start DESC);

--
-- Name: machine_downtime fk_md_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_downtime
    ADD CONSTRAINT fk_md_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_downtime fk_md_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_downtime
    ADD CONSTRAINT fk_md_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--

--
-- Hypertable & Compression Configuration
--

-- Convert to Hypertable (7-day chunks for High Frequency)
SELECT create_hypertable(relation => 'silver.machine_downtime'::regclass, time_column_name => 'down_start'::name, chunk_time_interval => INTERVAL '7 days', if_not_exists => TRUE);

-- Enable Compression
ALTER TABLE silver.machine_downtime SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id',
    timescaledb.compress_orderby = 'logical_date ASC'
);

-- Add Compression Policy (Compress after 30 days)
SELECT add_compression_policy(relation => 'silver.machine_downtime'::regclass, compress_after => INTERVAL '30 days');

