--
-- Name: machine_tool_usage; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_tool_usage (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    tool_no text NOT NULL,
    target_count integer,
    actual_count integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_tool_usage_logical_date_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_tool_usage_logical_date_idx ON silver.machine_tool_usage USING btree (logical_date DESC);

--
-- Name: machine_tool_usage fk_mtu_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_tool_usage
    ADD CONSTRAINT fk_mtu_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_tool_usage fk_mtu_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_tool_usage
    ADD CONSTRAINT fk_mtu_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- Hypertable & Compression Configuration
--

-- Convert to Hypertable (1-month chunks for Low/Medium Frequency)
SELECT create_hypertable(relation => 'silver.machine_tool_usage'::regclass, time_column_name => 'logical_date'::name, chunk_time_interval => INTERVAL '1 month', if_not_exists => TRUE);

-- Enable Compression
ALTER TABLE silver.machine_tool_usage SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id, tool_no',
    timescaledb.compress_orderby = 'logical_date ASC'
);

-- Add Compression Policy (Compress after 3 months)
SELECT add_compression_policy(relation => 'silver.machine_tool_usage'::regclass, compress_after => INTERVAL '3 months');

