--
-- PostgreSQL database dump
--

--
-- Name: shifts; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.shifts (
    id serial4 NOT NULL,
    company_iot_id integer NOT NULL,
    shift_name text DEFAULT NULL,
    shift_id int2 DEFAULT 0 NOT NULL,
    is_running bool DEFAULT false NULL,
    from_day int2 DEFAULT 0 NULL,
    to_day int2 DEFAULT 0 NULL,
    from_time timestamp NULL,
    to_time timestamp NULL,
    updated_ts timestamp NULL,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: shifts shifts_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.shifts
    ADD CONSTRAINT shifts_pkey PRIMARY KEY (id);

--
-- Name: shifts shifts_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.shifts
    ADD CONSTRAINT shifts_company_iot_id_fkey FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- PostgreSQL database dump complete
--


