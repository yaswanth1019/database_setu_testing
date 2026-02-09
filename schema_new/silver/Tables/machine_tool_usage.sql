--
-- Name: machine_tool_usage; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_tool_usage (
    logical_date timestamp with time zone NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name varchar(50),
    tool_no varchar(50) NOT NULL,
    target_count integer,
    actual_count integer,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: machine_tool_usage_logical_date_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_tool_usage_logical_date_idx ON silver.machine_tool_usage USING btree (logical_date DESC);

--
-- Name: machine_tool_usage fk_mtu_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_tool_usage
    ADD CONSTRAINT fk_mtu_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

--
-- Name: machine_tool_usage fk_mtu_machine; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_tool_usage
    ADD CONSTRAINT fk_mtu_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);
