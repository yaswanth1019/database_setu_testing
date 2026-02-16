--
-- Name: machine_timeline; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_timeline (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    state_code text, -- e.g., 'RUNNING', 'IDLE', 'DOWN'
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    duration_sec integer,
    created_at timestamp with time zone DEFAULT now()
);

-- Indices
CREATE INDEX machine_timeline_start_time_idx ON silver.machine_timeline USING btree (start_time DESC);
CREATE INDEX machine_timeline_machine_date_idx ON silver.machine_timeline (machine_iot_id, logical_date);

-- Foreign Keys
ALTER TABLE ONLY silver.machine_timeline
    ADD CONSTRAINT fk_mt_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

ALTER TABLE ONLY silver.machine_timeline
    ADD CONSTRAINT fk_mt_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

-- Hypertable & Compression Configuration
SELECT create_hypertable(relation => 'silver.machine_timeline'::regclass, time_column_name => 'logical_date'::name, chunk_time_interval => INTERVAL '7 days', if_not_exists => TRUE);


ALTER TABLE silver.machine_timeline SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id',
    timescaledb.compress_orderby = 'start_time ASC'
);

SELECT add_compression_policy(relation => 'silver.machine_timeline'::regclass, compress_after => INTERVAL '30 days');
