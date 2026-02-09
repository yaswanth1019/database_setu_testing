--
-- PostgreSQL database dump
--



SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: shifts; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.shifts (
    id serial4 NOT NULL,
    company_iot_id integer NOT NULL,
    shift_name varchar(20) DEFAULT NULL::character varying NULL,
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


