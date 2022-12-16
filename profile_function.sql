CREATE OR REPLACE FUNCTION add_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE profile_account_login VARCHAR(32);
    generate_digit_id TEXT;
    digit_id VARCHAR(8);
    unnec INTEGER;
BEGIN
    IF (SELECT COUNT(*) FROM profile) > 0 THEN
        unnec := (SELECT setval('generate_8digit_id',
            (SELECT MAX(substring(profile_id FROM 3 FOR 8)::INTEGER) FROM profile)));
    ELSE
        unnec := (SELECT setval('generate_8digit_id', 1, FALSE));
    END IF;
    profile_account_login := (SELECT account.account_login FROM account
    LEFT JOIN profile ON profile.account_login = account.account_login
    WHERE profile_id IS NULL LIMIT 1);
    generate_digit_id := (SELECT nextval('generate_8digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 8, '0');
    INSERT INTO profile(profile_id, profile_date_of_birth, account_login)
    VALUES (concat('id', digit_id), CURRENT_DATE, profile_account_login);

    IF (SELECT COUNT(*) FROM shopping_cart) > 0 THEN
        unnec := (SELECT setval('generate_8digit_id',
            (SELECT MAX(substring(shopping_cart_id FROM 3 FOR 8)::INTEGER)
             FROM shopping_cart)));
    ELSE
        unnec := (SELECT setval('generate_8digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_8digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 8, '0');
    INSERT INTO shopping_cart(shopping_cart_id, confirm_payment, account_login)
    VALUES (concat('sc', digit_id), FALSE, profile_account_login);

    RETURN NULL;
END;$$;

CREATE OR REPLACE TRIGGER add_profile_trigger
    AFTER INSERT ON account
    FOR EACH ROW
    EXECUTE FUNCTION add_profile();

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



DROP TRIGGER add_profile_trigger ON account;
DROP FUNCTION add_profile;