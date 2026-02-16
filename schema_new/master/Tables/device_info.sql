--
-- PostgreSQL database dump
--

--
-- Name: device_info; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.device_info (
    device_iot_id SERIAL NOT NULL,
    device_id text NOT NULL,
    description text,
    is_assigned boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    created_by text,
    updated_at timestamp with time zone
);

--
-- Name: device_info device_info_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.device_info
    ADD CONSTRAINT device_info_pkey PRIMARY KEY (device_iot_id);

--
-- Name: device_info device_info_device_id_key; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.device_info
    ADD CONSTRAINT device_info_device_id_key UNIQUE (device_id);

--
-- PostgreSQL database dump complete
--

