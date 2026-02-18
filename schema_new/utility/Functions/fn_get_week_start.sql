/*
    OBJECT: fn_get_week_start
    AUTHOR: Amith B R
    PURPOSE: Returns the ISO week start date (Monday) for a given timestamp.
             Result is returned in UTC.
    USAGE: SELECT utility.fn_get_week_start(now());
*/

CREATE OR REPLACE FUNCTION utility.fn_get_week_start(p_date date)
RETURNS timestamp
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN date_trunc('week', p_date);
END;
$$;
