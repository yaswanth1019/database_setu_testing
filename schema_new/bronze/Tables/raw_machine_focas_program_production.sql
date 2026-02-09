--
-- Name: raw_machine_focas_program_production; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_focas_program_production (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    shift_id integer,
    program_no varchar(50),
    actual_count integer,
    target_count integer,
    std_load_unload integer,
    std_cycle_time integer,
    cnctimestamp timestamp with time zone
);

--
-- Name: raw_machine_focas_program_production raw_machine_focas_program_production_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_focas_program_production
    ADD CONSTRAINT raw_machine_focas_program_production_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_fpp_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_fpp_watermark ON bronze.raw_machine_focas_program_production USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.raw_machine_focas_program_production', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.raw_machine_focas_program_production', INTERVAL '30 days');
