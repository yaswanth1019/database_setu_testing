--
-- PostgreSQL database dump
--

--
-- Name: downtime_codes; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.downtime_codes (
    down_id SERIAL NOT NULL,
    down_code text NOT NULL,
    description text,
    category text,
    threshold_sec integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: downtime_codes downtime_codes_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.downtime_codes
    ADD CONSTRAINT downtime_codes_pkey PRIMARY KEY (down_id);

--
-- PostgreSQL database dump complete
--


