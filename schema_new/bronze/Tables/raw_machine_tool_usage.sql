--
-- Name: raw_machine_tool_usage; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_tool_usage (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    tool_no varchar(50) NOT NULL,
    target_count integer,
    actual_count integer
);

--
-- Name: raw_machine_tool_usage raw_machine_tool_usage_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_tool_usage
    ADD CONSTRAINT raw_machine_tool_usage_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_tool_usage_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_tool_usage_watermark ON bronze.raw_machine_tool_usage USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.raw_machine_tool_usage', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.raw_machine_tool_usage', INTERVAL '30 days');
