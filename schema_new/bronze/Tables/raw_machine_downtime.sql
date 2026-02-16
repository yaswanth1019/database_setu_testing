--
-- Name: raw_machine_downtime; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_downtime (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    down_start timestamp with time zone,
    down_end timestamp with time zone,
    program_no text,
    down_id integer,
    down_threshold integer
);

--
-- Name: raw_machine_downtime raw_machine_downtime_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_downtime
    ADD CONSTRAINT raw_machine_downtime_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_downtime_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_downtime_watermark ON bronze.raw_machine_downtime USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable(relation => 'bronze.raw_machine_downtime'::regclass, time_column_name => 'ingested_at'::name, chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy(relation => 'bronze.raw_machine_downtime'::regclass, drop_after => INTERVAL '30 days');

