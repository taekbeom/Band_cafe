DROP SEQUENCE generate_4digit_id;
DROP SEQUENCE generate_8digit_id;
DROP SEQUENCE generate_12digit_id;

CREATE SEQUENCE IF NOT EXISTS generate_4digit_id
MINVALUE 1
MAXVALUE 9999;

CREATE SEQUENCE IF NOT EXISTS generate_8digit_id
MINVALUE 1
MAXVALUE 99999999;

CREATE SEQUENCE IF NOT EXISTS generate_12digit_id
MINVALUE 1
MAXVALUE 999999999999;

CREATE OR REPLACE FUNCTION is_date(date_string TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM date_string::DATE;
    RETURN TRUE;
    EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;$$;