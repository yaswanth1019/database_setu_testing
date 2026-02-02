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
-- Name: machine_tool_usage; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_tool_usage (
    logical_date timestamp with time zone NOT NULL,
    company_id text NOT NULL,
    machine_iot_id integer NOT NULL,
    shift_id integer,
    shift_name varchar(50),
    tool_no varchar(50) NOT NULL,
    target_count integer,
    actual_count integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_tool_usage_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_tool_usage_logical_date_idx ON silver.machine_tool_usage USING btree (logical_date DESC);


--
-- PostgreSQL database dump complete
--


