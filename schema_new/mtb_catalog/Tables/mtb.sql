--
-- Name: mtb; Type: TABLE; Schema: mtb_catalog; Owner: -
--

CREATE TABLE mtb_catalog.mtb (
    mtb_id SERIAL NOT NULL,
    name text NOT NULL,
    short_name text,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: mtb mtb_pkey; Type: CONSTRAINT; Schema: mtb_catalog; Owner: -
--

ALTER TABLE ONLY mtb_catalog.mtb
    ADD CONSTRAINT mtb_pkey PRIMARY KEY (mtb_id);

