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
    SET profile_avatar_source = COALESCE(new_profile_avatar,
        profile_avatar_source),
        profile_date_of_birth = new_profile_date,
    profile_description = COALESCE(new_profile_description,
        profile_description)
    WHERE account_login = upd_account_login;
END;$$;

CREATE OR REPLACE PROCEDURE delete_avatar(upd_account_login VARCHAR(32))
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE profile SET profile_avatar_source = NULL
    WHERE account_login = upd_account_login;
END;$$;

CREATE OR REPLACE PROCEDURE delete_description(upd_account_login VARCHAR(32))
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE profile SET profile_description = NULL
    WHERE account_login = upd_account_login;
END;$$;

CREATE OR REPLACE PROCEDURE delete_date(upd_account_login VARCHAR(32))
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE profile SET profile_date_of_birth = NULL
    WHERE account_login = upd_account_login;
END;$$;

CALL update_profile('oleshandra', 'on', '2010-01-15');
CALL delete_avatar('oleshandra');
SELECT delete_date('');


(SELECT account.account_login FROM account
    LEFT JOIN profile ON profile.account_login = account.account_login
    WHERE profile_id IS NULL LIMIT 1);

SELECT * FROM profile;
SELECT * FROM shopping_cart;
DELETE FROM profile;
DELETE FROM shopping_cart;



-- DROP TRIGGER add_profile_trigger ON account;
-- DROP FUNCTION add_profile;

DROP FUNCTION update_profile(upd_account_login VARCHAR(32),
new_profile_avatar TEXT,
new_profile_string_date TEXT,
new_profile_description VARCHAR(64))