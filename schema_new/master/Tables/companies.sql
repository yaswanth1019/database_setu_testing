--
-- PostgreSQL database dump
--

--
-- Name: companies; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.companies (
    iot_id SERIAL NOT NULL,
    company_id text NOT NULL,
    company_name text NOT NULL,
    address text,
    state text,
    country text,
    pin_code text,
    email_id text,
    phone_no text,
    default_plant_id integer,
    effective_from_date timestamp with time zone,
    effective_to_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (iot_id);

ALTER TABLE ONLY master.companies
    ADD CONSTRAINT uq_company_id UNIQUE (company_id);

--
-- PostgreSQL database dump complete
--


