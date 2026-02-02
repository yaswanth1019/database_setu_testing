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
-- Name: machine_focas; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_focas (
    logical_date timestamp with time zone NOT NULL,
    company_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name varchar(50),
    part_count integer,
    rej_count integer,
    pot integer,
    ot integer,
    ct integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_focas_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_focas_logical_date_idx ON silver.machine_focas USING btree (logical_date DESC);


--
-- Name: machine_focas fk_mf_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_focas
    ADD CONSTRAINT fk_mf_company FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


