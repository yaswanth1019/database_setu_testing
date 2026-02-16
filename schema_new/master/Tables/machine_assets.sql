--
-- PostgreSQL database dump
--

--
-- Name: machine_assets; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.machine_assets (
    machine_iot_id integer NOT NULL,
    company_iot_id integer NOT NULL,
    supplier_name text,
    model_number text,
    manufacturing_year integer,
    commissioned_date date,
    warranty_expire_date date,
    subscription_tier text DEFAULT 'Freemium' CHECK (subscription_tier IN ('Freemium', 'Plus', 'Pro')),
    is_mvp2_enabled boolean DEFAULT false,
    customer_address text,
    support_contact text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);

--
-- Name: machine_assets machine_assets_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_assets
    ADD CONSTRAINT machine_assets_pkey PRIMARY KEY (machine_iot_id, company_iot_id);

--
-- Name: machine_assets machine_assets_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_assets
    ADD CONSTRAINT machine_assets_company_iot_id_fkey FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_assets machine_assets_machine_iot_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -

ALTER TABLE ONLY master.machine_assets
    ADD CONSTRAINT machine_assets_machine_iot_id_fkey FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--


