--
-- Name: stg_machine_am_status; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_am_status (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    shift_id integer,
    cnctimestamp timestamp with time zone,
    status varchar(50),
    am_corrected_count integer,
    am_pending_count integer
);

--
-- Name: stg_machine_am_status stg_machine_am_status_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_am_status
    ADD CONSTRAINT stg_machine_am_status_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_am_status_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_am_status_watermark ON bronze.stg_machine_am_status USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_am_status', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_am_status', INTERVAL '30 days');
