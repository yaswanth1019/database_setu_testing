--
-- PostgreSQL database dump
--

--
-- Name: plant_machine_mapping; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.plant_machine_mapping (
    mapping_id SERIAL NOT NULL,
    plant_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: plant_machine_mapping plant_machine_mapping_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT plant_machine_mapping_pkey PRIMARY KEY (mapping_id);

--
-- Name: plant_machine_mapping uq_plant_machine; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT uq_plant_machine UNIQUE (plant_id, machine_iot_id);

--
-- Name: plant_machine_mapping plant_machine_mapping_plant_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT plant_machine_mapping_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES master.plants(plant_id);

--
-- Name: plant_machine_mapping plant_machine_mapping_machine_iot_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT plant_machine_mapping_machine_iot_id_fkey FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--

