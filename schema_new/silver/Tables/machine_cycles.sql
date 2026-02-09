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
-- Name: machine_cycles; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_cycles (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name varchar(50),
    cycle_start timestamp with time zone,
    cycle_end timestamp with time zone,
    program_no varchar(50),
    std_load_unload integer,
    std_cycle_time integer,
    actual_load_unload integer,
    actual_cycle_time integer,
    down_threshold integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: COLUMN machine_cycles.down_threshold; Type: COMMENT; Schema: silver; Owner: -
--

COMMENT ON COLUMN silver.machine_cycles.down_threshold IS 'Threshold in seconds for detecting downtime during load/unload. From legacy DownThreshold field.';


--
-- Name: machine_cycles_cycle_start_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_cycles_cycle_start_idx ON silver.machine_cycles USING btree (cycle_start DESC);


--
-- Name: machine_cycles fk_mc_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_cycles
    ADD CONSTRAINT fk_mc_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);


--
-- Name: machine_cycles fk_mc_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_cycles
    ADD CONSTRAINT fk_mc_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);


--
-- PostgreSQL database dump complete
--


