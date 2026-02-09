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
-- Name: machine_am_status; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_am_status (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name varchar(50),
    status varchar(50),
    am_corrected_count integer,
    am_pending_count integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_am_status_logical_date_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_am_status_logical_date_idx ON silver.machine_am_status USING btree (logical_date DESC);


--
-- Name: machine_am_status fk_am_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_am_status
    ADD CONSTRAINT fk_am_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);


--
-- Name: machine_am_status fk_am_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_am_status
    ADD CONSTRAINT fk_am_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);


--
-- PostgreSQL database dump complete
--
