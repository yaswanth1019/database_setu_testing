--
-- Name: shift_definitions; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.shift_definitions (
    id serial NOT NULL,
    company_iot_id integer NOT NULL,
    shift_name text,
    shift_id int2 NOT NULL, -- Logical shift ID (1, 2, 3...)
    from_day int2 DEFAULT 0 NOT NULL, -- 0 for current logical date, 1 for next
    to_day int2 DEFAULT 0 NOT NULL,   -- 0 for current logical date, 1 for next
    start_time time NOT NULL, -- e.g., '06:00:00'
    end_time time NOT NULL,   -- e.g., '14:00:00'
    is_running boolean DEFAULT true,
    timezone text DEFAULT 'Asia/Kolkata' NOT NULL,
    updated_at timestamp DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);

-- Primary Key
ALTER TABLE ONLY master.shift_definitions
    ADD CONSTRAINT shift_definitions_pkey PRIMARY KEY (id);

-- Foreign Key
ALTER TABLE ONLY master.shift_definitions
    ADD CONSTRAINT shift_definitions_company_iot_id_fkey FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

-- Unique constraint to prevent duplicate shift codes per company
ALTER TABLE ONLY master.shift_definitions
    ADD CONSTRAINT shift_definitions_company_shift_unique UNIQUE (company_iot_id, shift_id);
