--
-- PostgreSQL database dump
--

--
-- Name: machine_info; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.machine_info (
    iot_id SERIAL NOT NULL,
    machine_id text NOT NULL,
    company_iot_id integer NOT NULL,
    device_id text,
    ip_address text,
    port_no integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_info machine_info_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_info
    ADD CONSTRAINT machine_info_pkey PRIMARY KEY (iot_id);

--
-- Name: machine_info uq_machine_company; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_info
    ADD CONSTRAINT uq_machine_company UNIQUE (machine_id, company_iot_id);

--
-- Name: machine_info machine_info_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_info
    ADD CONSTRAINT machine_info_company_iot_id_fkey FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_info machine_info_device_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_info
    ADD CONSTRAINT machine_info_device_id_fkey FOREIGN KEY (device_id) REFERENCES master.device_info(device_id);

--
-- PostgreSQL database dump complete
--


