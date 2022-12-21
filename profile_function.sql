CREATE OR REPLACE PROCEDURE update_profile(upd_account_login VARCHAR(32),
new_profile_avatar TEXT DEFAULT NULL,
new_profile_string_date TEXT DEFAULT NULL,
new_profile_description VARCHAR(64) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE new_profile_date DATE;
BEGIN
        IF new_profile_description IS NOT NULL AND length(new_profile_description) = 0 THEN
            new_profile_description := NULL;
        END IF;
        new_profile_date := (SELECT profile_date_of_birth FROM profile
        WHERE account_login = upd_account_login);
        IF new_profile_description IS NOT NULL AND
           length(new_profile_description) = 0 THEN
            new_profile_description := (SELECT profile_description
                                        FROM profile
                                        WHERE account_login = upd_account_login);
        END IF;
    IF (is_date(new_profile_string_date) AND
        to_date(new_profile_string_date, 'yyyy-mm-dd') IS NOT NULL) THEN
        new_profile_date := to_date(new_profile_string_date, 'yyyy-mm-dd');
    END IF;
    UPDATE profile
    SET profile_avatar_source = new_profile_avatar,
        profile_date_of_birth = new_profile_date,
    profile_description = COALESCE(new_profile_description,
        profile_description)
    WHERE account_login = upd_account_login;
    IF (SELECT role_id FROM account WHERE account_login
                                              = upd_account_login) = 2 THEN
        UPDATE member
        SET member_date_of_birth =  new_profile_date
        WHERE member_id = (SELECT member_id FROM member_profile
            JOIN profile ON member_profile.profile_id = profile.profile_id
            WHERE account_login = upd_account_login);
    END IF;
END;$$;
