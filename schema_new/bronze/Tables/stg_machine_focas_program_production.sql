--
-- Name: stg_machine_focas_program_production; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_focas_program_production (
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
-- Name: stg_machine_focas_program_production stg_machine_focas_program_production_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_focas_program_production
    ADD CONSTRAINT stg_machine_focas_program_production_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_fpp_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_fpp_watermark ON bronze.stg_machine_focas_program_production USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_focas_program_production', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_focas_program_production', INTERVAL '30 days');
