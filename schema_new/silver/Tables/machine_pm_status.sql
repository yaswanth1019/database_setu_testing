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
-- Name: machine_pm_status; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_pm_status (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    status varchar(50),
    pm_corrected_count integer,
    pm_pending_count integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_pm_status_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_pm_status_logical_date_idx ON silver.machine_pm_status USING btree (logical_date DESC);


--
-- Name: machine_pm_status fk_pm_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_pm_status
    ADD CONSTRAINT fk_pm_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);


--
-- PostgreSQL database dump complete
--


