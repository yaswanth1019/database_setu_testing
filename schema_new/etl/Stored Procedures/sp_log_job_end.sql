/*
    OBJECT: sp_log_job_end
    AUTHOR: Amith B R
    PURPOSE: Updates the job log entry with completion status and metrics.
    TARGET TABLE: etl.control_job_log
    DEPENDENCIES: None
*/

CREATE OR REPLACE PROCEDURE etl.sp_log_job_end(
    p_log_id INT, 
    p_status TEXT, 
    p_rows INT, 
    p_msg TEXT
) 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
    UPDATE etl.control_job_log 
    SET end_time = NOW(), 
        status = p_status, 
        rows_affected = p_rows, 
        message = p_msg
    WHERE log_id = p_log_id;
END;
$$;
