--
-- PostgreSQL database dump
--

--
-- Name: machine_status; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_status (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name text,
    program_no text,
    status text,
    operator_id text,
    target integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_status_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_status_logical_date_idx ON silver.machine_status USING btree (logical_date DESC);

--
-- Name: machine_status fk_ms_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_status
    ADD CONSTRAINT fk_ms_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_status fk_ms_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_status
    ADD CONSTRAINT fk_ms_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--


