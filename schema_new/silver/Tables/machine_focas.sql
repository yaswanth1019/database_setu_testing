--
-- PostgreSQL database dump
--

--
-- Name: machine_focas; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_focas (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    part_count integer,
    rej_count integer,
    pot integer,
    ot integer,
    ct integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_focas_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_focas_logical_date_idx ON silver.machine_focas USING btree (logical_date DESC);

--
-- Name: machine_focas fk_mf_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_focas
    ADD CONSTRAINT fk_mf_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_focas fk_mf_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_focas
    ADD CONSTRAINT fk_mf_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--

--
-- Hypertable & Compression Configuration
--

-- Convert to Hypertable (1-month chunks for Low Frequency)
SELECT create_hypertable(relation => 'silver.machine_focas'::regclass, time_column_name => 'logical_date'::name, chunk_time_interval => INTERVAL '1 month', if_not_exists => TRUE);

-- Enable Compression
ALTER TABLE silver.machine_focas SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id',
    timescaledb.compress_orderby = 'logical_date ASC'
);

-- Add Compression Policy (Compress after 3 months)
SELECT add_compression_policy(relation => 'silver.machine_focas'::regclass, compress_after => INTERVAL '3 months');

