CREATE OR REPLACE FUNCTION add_user(user_login VARCHAR(32),
						  user_password TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
    DECLARE generate_digit_id TEXT;
    digit_id VARCHAR(8);
    unnec INTEGER;
BEGIN
IF (SELECT COUNT(*) FROM account WHERE account_login = user_login) THEN
    RETURN FALSE;
ELSE
    INSERT INTO account(account_login, account_password)
    VALUES(user_login, crypt(user_password, gen_salt('bf', 8)));
    EXECUTE FORMAT('CREATE USER %I WITH PASSWORD %L;', user_login, user_password);
    EXECUTE FORMAT('GRANT user_role TO %I;', user_login);
END IF;
IF (SELECT COUNT(*) FROM profile) > 0 THEN
        unnec := (SELECT setval('generate_8digit_id',
            (SELECT MAX(substring(profile_id FROM 3 FOR 8)::INTEGER) FROM profile)));
    ELSE
        unnec := (SELECT setval('generate_8digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_8digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 8, '0');
    INSERT INTO profile(profile_id, profile_date_of_birth, account_login)
    VALUES (concat('id', digit_id), CURRENT_DATE, user_login);

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
    VALUES (concat('sc', digit_id), FALSE, user_login);
RETURN TRUE;
END; $$;

CREATE OR REPLACE FUNCTION update_user(old_login VARCHAR(32),
new_login VARCHAR(32) DEFAULT NULL,
new_password TEXT DEFAULT NULL,
new_role_id NUMERIC(1) DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
    DECLARE login_change VARCHAR(32);
        role_id_change NUMERIC(1);
        role_name_change VARCHAR(32);
BEGIN
        login_change := (SELECT COALESCE(new_login,
            (SELECT account_login FROM account
                                  WHERE account_login = old_login)));
        role_id_change := (SELECT COALESCE(new_role_id,
            (SELECT role_id FROM account
                                  WHERE account_login = old_login)));
        role_name_change := (SELECT role_name FROM account_role
                                              WHERE role_id = role_id_change);
        EXECUTE FORMAT('REVOKE %I FROM %I;',
            (SELECT role_name FROM account_role
            WHERE role_id = (SELECT role_id FROM account
            WHERE account_login = old_login)),
            old_login);
        EXECUTE FORMAT('GRANT user_role TO %I',
            old_login);
        IF role_id_change < 3 THEN
        EXECUTE FORMAT('GRANT %I TO %I;',
            role_name_change, old_login);
        END IF;

        UPDATE account SET
    account_login = login_change,
    account_password = COALESCE(crypt(new_password, gen_salt('bf')),
        account_password),
    role_id = role_id_change
    WHERE account_login = old_login;
    IF new_password IS NOT NULL THEN
        EXECUTE FORMAT('ALTER USER %I WITH PASSWORD %L;',
            old_login, new_password);
    END IF;
    IF old_login != login_change THEN
        EXECUTE FORMAT('ALTER USER %I RENAME TO %I;',
            old_login, login_change);
    END IF;
    RETURN TRUE;
END;$$;

CREATE OR REPLACE FUNCTION delete_user(delete_login VARCHAR(32))
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT COUNT(*) FROM account WHERE account_login = delete_login) THEN
    EXECUTE FORMAT('DROP USER %I', delete_login);
    DELETE FROM profile WHERE account_login = delete_login;
    DELETE FROM shopping_cart WHERE account_login = delete_login;
    DELETE FROM account WHERE account_login = delete_login;
    RETURN TRUE;
    END IF;
    RETURN FALSE;
END;$$;

SELECT * FROM add_user('oleshandra', 'popovich');
SELECT * FROM account;
SELECT * FROM update_user('oleshandr', null, null, 1);
SELECT * FROM delete_user('oleshandra')

DELETE FROM account WHERE account_login = 'olesha';
DROP ROLE oleshandra;

DROP FUNCTION update_user(old_login VARCHAR(32),
new_login VARCHAR(32),
new_password TEXT,
new_role_id NUMERIC(1))