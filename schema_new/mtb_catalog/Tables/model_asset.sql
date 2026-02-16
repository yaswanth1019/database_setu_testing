--
-- Name: model_asset; Type: TABLE; Schema: mtb_catalog; Owner: -
--

CREATE TABLE mtb_catalog.model_asset (
    asset_id SERIAL NOT NULL,
    model_id integer NOT NULL,
    asset_type text NOT NULL,
    asset_title text,
    blob_container text NOT NULL,
    blob_path text NOT NULL,
    blob_url text NOT NULL,
    file_format text,
    language text DEFAULT 'en',
    version text,
    is_primary boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: model_asset model_asset_pkey; Type: CONSTRAINT; Schema: mtb_catalog; Owner: -
--

ALTER TABLE ONLY mtb_catalog.model_asset
    ADD CONSTRAINT model_asset_pkey PRIMARY KEY (asset_id);

--
-- Name: model_asset chk_asset_type; Type: CHECK CONSTRAINT; Schema: mtb_catalog; Owner: -
--

ALTER TABLE mtb_catalog.model_asset
    ADD CONSTRAINT chk_asset_type CHECK (asset_type IN ('manual', 'image', 'brochure', 'video'));

--
-- Name: model_asset model_asset_model_id_fkey; Type: FK CONSTRAINT; Schema: mtb_catalog; Owner: -
--

ALTER TABLE ONLY mtb_catalog.model_asset
    ADD CONSTRAINT model_asset_model_id_fkey FOREIGN KEY (model_id) REFERENCES mtb_catalog.machine_model(model_id) ON DELETE CASCADE;

