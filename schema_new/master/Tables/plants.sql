--
-- PostgreSQL database dump
--

--
-- Name: plants; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.plants (
    plant_id SERIAL NOT NULL,
    company_iot_id integer NOT NULL,
    plant_name text,
    plant_city text,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: plants plants_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.plants
    ADD CONSTRAINT plants_pkey PRIMARY KEY (plant_id);

--
-- Name: plants plants_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.plants
    ADD CONSTRAINT plants_company_iot_id_fkey FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- PostgreSQL database dump complete
--


