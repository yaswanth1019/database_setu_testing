--
-- Name: raw_machine_pm_status; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_pm_status (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    cnctimestamp timestamp with time zone,
    status varchar(50),
    pm_corrected_count integer,
    pm_pending_count integer
);

--
-- Name: raw_machine_pm_status raw_machine_pm_status_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_pm_status
    ADD CONSTRAINT raw_machine_pm_status_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_pm_status_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_pm_status_watermark ON bronze.raw_machine_pm_status USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.raw_machine_pm_status', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.raw_machine_pm_status', INTERVAL '30 days');
