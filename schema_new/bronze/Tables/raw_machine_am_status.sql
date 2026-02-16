--
-- Name: raw_machine_am_status; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_am_status (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    shift_id integer,
    cnctimestamp timestamp with time zone,
    status text,
    am_corrected_count integer,
    am_pending_count integer
);

--
-- Name: raw_machine_am_status raw_machine_am_status_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_am_status
    ADD CONSTRAINT raw_machine_am_status_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_am_status_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_am_status_watermark ON bronze.raw_machine_am_status USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable(relation => 'bronze.raw_machine_am_status'::regclass, time_column_name => 'ingested_at'::name, chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy(relation => 'bronze.raw_machine_am_status'::regclass, drop_after => INTERVAL '30 days');

