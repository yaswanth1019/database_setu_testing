--
-- Name: raw_machine_focas; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_machine_focas (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    logical_date timestamp with time zone,
    shift_id integer,
    cnctimestamp timestamp with time zone,
    part_count integer,
    rej_count integer,
    pot integer,
    ot integer,
    ct integer
);

--
-- Name: raw_machine_focas raw_machine_focas_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_machine_focas
    ADD CONSTRAINT raw_machine_focas_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_raw_machine_focas_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_machine_focas_watermark ON bronze.raw_machine_focas USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable(relation => 'bronze.raw_machine_focas'::regclass, time_column_name => 'ingested_at'::name, chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy(relation => 'bronze.raw_machine_focas'::regclass, drop_after => INTERVAL '30 days');

