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
-- Name: machine_energy; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_energy (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name varchar(50),
    category varchar(50),
    servo_energy numeric(12,3),
    spindle_energy numeric(12,3),
    total_energy numeric(12,3),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_energy_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_energy_logical_date_idx ON silver.machine_energy USING btree (logical_date DESC);


--
-- Name: machine_energy fk_me_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_energy
    ADD CONSTRAINT fk_me_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);


--
-- Name: machine_energy fk_me_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_energy
    ADD CONSTRAINT fk_me_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);


--
-- PostgreSQL database dump complete
--


