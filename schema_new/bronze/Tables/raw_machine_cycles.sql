--
-- Name: raw_machine_cycles; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_cycles (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    cycle_start timestamp with time zone,
    cycle_end timestamp with time zone,
    program_no text,
    std_load_unload integer,
    std_cycle_time integer,
    down_threshold integer
);

--
-- Name: raw_machine_cycles raw_machine_cycles_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_cycles
    ADD CONSTRAINT raw_machine_cycles_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_cycles_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_cycles_watermark ON bronze.raw_machine_cycles USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable(relation => 'bronze.raw_machine_cycles'::regclass, time_column_name => 'ingested_at'::name, chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy(relation => 'bronze.raw_machine_cycles'::regclass, drop_after => INTERVAL '30 days');

