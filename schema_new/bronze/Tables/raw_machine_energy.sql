--
-- Name: raw_machine_energy; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_energy (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    category text,
    servo_energy numeric(12,3),
    spindle_energy numeric(12,3),
    total_energy numeric(12,3)
);

--
-- Name: raw_machine_energy raw_machine_energy_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_energy
    ADD CONSTRAINT raw_machine_energy_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_energy_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_energy_watermark ON bronze.raw_machine_energy USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable(relation => 'bronze.raw_machine_energy'::regclass, time_column_name => 'ingested_at'::name, chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy(relation => 'bronze.raw_machine_energy'::regclass, drop_after => INTERVAL '30 days');

