--
-- Name: fn_log_job_start; Type: FUNCTION; Schema: etl; Owner: -
--

CREATE OR REPLACE FUNCTION etl.fn_log_job_start(
    p_job_name TEXT, 
    p_type TEXT
) 
RETURNS INT 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
DECLARE 
    v_log_id INT;
BEGIN
    INSERT INTO etl.control_job_log (job_name, status, execution_type)
    VALUES (p_job_name, 'RUNNING', p_type)
    RETURNING log_id INTO v_log_id;
    
    RETURN v_log_id;
END;
$$;
