--
-- PostgreSQL database dump
--

--
-- Name: machine_cycles; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_cycles (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    cycle_start timestamp with time zone,
    cycle_end timestamp with time zone,
    program_no text,
    std_load_unload integer,
    std_cycle_time integer,
    actual_load_unload integer,
    actual_cycle_time integer,
    down_threshold integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: COLUMN machine_cycles.down_threshold; Type: COMMENT; Schema: silver; Owner: -
--

COMMENT ON COLUMN silver.machine_cycles.down_threshold IS 'Threshold in seconds for detecting downtime during load/unload. From legacy DownThreshold field.';

--
-- Name: machine_cycles_cycle_start_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_cycles_cycle_start_idx ON silver.machine_cycles USING btree (cycle_start DESC);

--
-- Name: machine_cycles fk_mc_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_cycles
    ADD CONSTRAINT fk_mc_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_cycles fk_mc_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_cycles
    ADD CONSTRAINT fk_mc_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--

--
-- Hypertable & Compression Configuration
--

-- Convert to Hypertable (7-day chunks for High Frequency)
SELECT create_hypertable(relation => 'silver.machine_cycles'::regclass, time_column_name => 'cycle_start'::name, chunk_time_interval => INTERVAL '7 days', if_not_exists => TRUE);

-- Enable Compression
ALTER TABLE silver.machine_cycles SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id',
    timescaledb.compress_orderby = 'logical_date ASC'
);

-- Add Compression Policy (Compress after 30 days)
SELECT add_compression_policy(relation => 'silver.machine_cycles'::regclass, compress_after => INTERVAL '30 days');

