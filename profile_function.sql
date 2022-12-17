CREATE OR REPLACE PROCEDURE update_profile(upd_account_login VARCHAR(32),
new_profile_avatar TEXT DEFAULT NULL,
new_profile_string_date TEXT DEFAULT NULL,
new_profile_description VARCHAR(64) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE new_profile_date DATE;
BEGIN
        new_profile_date := (SELECT profile_date_of_birth FROM profile
        WHERE account_login = upd_account_login);
    IF (is_date(new_profile_string_date) AND
        to_date(new_profile_string_date, 'yyyy-mm-dd') IS NOT NULL) THEN
        new_profile_date := to_date(new_profile_string_date, 'yyyy-mm-dd');
    END IF;
    UPDATE profile
    SET profile_avatar_source = new_profile_avatar,
        profile_date_of_birth = new_profile_date,
    profile_description = new_profile_description
    WHERE account_login = upd_account_login;
END;$$;
