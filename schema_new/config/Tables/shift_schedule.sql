--
-- Name: shift_schedule; Type: TABLE; Schema: config; Owner: -
-- NOTE: This table stores materialized shift start and end times for operational use.
--

CREATE TABLE config.shift_schedule (
    id serial NOT NULL,
    company_iot_id integer NOT NULL,
    shift_name text,
    shift_id int2 NOT NULL,
    shift_start_time timestamp with time zone NOT NULL,
    shift_end_time timestamp with time zone NOT NULL,
    period tstzrange GENERATED ALWAYS AS (
        tstzrange(shift_start_time, shift_end_time, '[)')
    ) STORED,
    logical_date date NOT NULL, -- The date this shift 'belongs' to
    created_at timestamp with time zone DEFAULT now()
);

-- Primary Key
ALTER TABLE ONLY config.shift_schedule
    ADD CONSTRAINT shift_schedule_pkey PRIMARY KEY (id);

-- GIST Index for range lookups
CREATE INDEX shift_schedule_period_gist_idx ON config.shift_schedule USING gist (period);

-- Foreign Key
ALTER TABLE ONLY config.shift_schedule
    ADD CONSTRAINT shift_schedule_company_iot_id_fkey FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

-- Indices for performance
CREATE INDEX shift_schedule_lookup_idx ON config.shift_schedule (company_iot_id, logical_date);
CREATE INDEX shift_schedule_range_idx ON config.shift_schedule (shift_start_time, shift_end_time);

-- Unique constraint to prevent duplicate materialized shifts
ALTER TABLE ONLY config.shift_schedule
    ADD CONSTRAINT shift_schedule_unique UNIQUE (company_iot_id, logical_date, shift_id);
