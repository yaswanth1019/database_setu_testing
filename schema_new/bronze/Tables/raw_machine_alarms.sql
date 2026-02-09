--
-- Name: raw_machine_alarms; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_alarms (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    alarm_no integer,
    alarm_desc text
);

--
-- Name: raw_machine_alarms raw_machine_alarms_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_alarms
    ADD CONSTRAINT raw_machine_alarms_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_alarms_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_alarms_watermark ON bronze.raw_machine_alarms USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.raw_machine_alarms', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.raw_machine_alarms', INTERVAL '30 days');
