--
-- Name: machine_model; Type: TABLE; Schema: mtb_catalog; Owner: -
--

CREATE TABLE mtb_catalog.machine_model (
    model_id SERIAL NOT NULL,
    mtb_id integer NOT NULL,
    model_name text NOT NULL,
    model_code text,
    model_type text,
    description text,
    status text DEFAULT 'active',
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: machine_model machine_model_pkey; Type: CONSTRAINT; Schema: mtb_catalog; Owner: -
--

ALTER TABLE ONLY mtb_catalog.machine_model
    ADD CONSTRAINT machine_model_pkey PRIMARY KEY (model_id);

--
-- Name: machine_model uq_mtb_model; Type: CONSTRAINT; Schema: mtb_catalog; Owner: -
--

ALTER TABLE ONLY mtb_catalog.machine_model
    ADD CONSTRAINT uq_mtb_model UNIQUE (mtb_id, model_name);

--
-- Name: machine_model machine_model_mtb_id_fkey; Type: FK CONSTRAINT; Schema: mtb_catalog; Owner: -
--

ALTER TABLE ONLY mtb_catalog.machine_model
    ADD CONSTRAINT machine_model_mtb_id_fkey FOREIGN KEY (mtb_id) REFERENCES mtb_catalog.mtb(mtb_id) ON DELETE CASCADE;

