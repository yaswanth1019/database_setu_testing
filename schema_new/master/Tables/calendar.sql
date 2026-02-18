--
-- Name: calendar; Type: TABLE; Schema: master; Owner: -
-- NOTE: All temporal data in this table is stored in UTC.
--

CREATE TABLE master.calendar (
    date_key integer NOT NULL,
    full_date timestamp with time zone NOT NULL,
    year integer NOT NULL,
    iso_year integer NOT NULL,
    month integer NOT NULL,
    iso_week integer NOT NULL,
    week_start_date timestamp with time zone NOT NULL,
    week_end_date timestamp with time zone NOT NULL,
    day_of_week integer NOT NULL,
    is_weekend boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

-- Indices
CREATE UNIQUE INDEX calendar_full_date_idx ON master.calendar (full_date);
CREATE INDEX calendar_year_month_idx ON master.calendar (year, month);

-- Primary Key
ALTER TABLE ONLY master.calendar
    ADD CONSTRAINT calendar_pkey PRIMARY KEY (date_key);
