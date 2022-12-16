CREATE OR REPLACE FUNCTION update_profile(upd_account_login VARCHAR(32),
new_profile_avatar TEXT DEFAULT NULL,
new_profile_description VARCHAR(64) DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE profile
    SET profile_avatar_source = COALESCE(new_profile_avatar,
        profile_avatar_source),
    profile_description = COALESCE(new_profile_description,
        profile_description)
    WHERE account_login = upd_account_login;
    RETURN TRUE;
END;$$;

CREATE OR REPLACE FUNCTION delete_avatar(upd_account_login VARCHAR(32))
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE profile SET profile_avatar_source = NULL
    WHERE account_login = upd_account_login;
    RETURN TRUE;
END;$$;

CREATE OR REPLACE FUNCTION delete_description(upd_account_login VARCHAR(32))
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE profile SET profile_description = NULL
    WHERE account_login = upd_account_login;
    RETURN TRUE;
END;$$;

SELECT update_profile('olleg', 'aa');
SELECT delete_avatar('olleg');

(SELECT account.account_login FROM account
    LEFT JOIN profile ON profile.account_login = account.account_login
    WHERE profile_id IS NULL LIMIT 1);

SELECT * FROM profile;
SELECT * FROM shopping_cart;
DELETE FROM profile;
DELETE FROM shopping_cart;



-- DROP TRIGGER add_profile_trigger ON account;
-- DROP FUNCTION add_profile;