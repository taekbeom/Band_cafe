CREATE OR REPLACE PROCEDURE add_user(user_login VARCHAR(32),
						  user_password TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
IF (SELECT COUNT(*) FROM account WHERE account_login = user_login) = 0 THEN
    INSERT INTO account(account_login, account_password)
    VALUES(user_login, crypt(user_password, gen_salt('bf', 8)));
    EXECUTE FORMAT('CREATE USER %I WITH PASSWORD %L;', user_login, user_password);
    EXECUTE FORMAT('GRANT user_role TO %I;', user_login);
    COMMIT;
END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_user(old_login VARCHAR(32),
new_login VARCHAR(32) DEFAULT NULL,
new_password TEXT DEFAULT NULL,
new_role_id NUMERIC(1) DEFAULT NULL)
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
    account_password = COALESCE(crypt(new_password, gen_salt('bf', 8)),
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
END;$$;

CREATE OR REPLACE PROCEDURE delete_user(delete_login VARCHAR(32))
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT COUNT(*) FROM account WHERE account_login = delete_login) THEN
    EXECUTE FORMAT('DROP USER %I', delete_login);
    DELETE FROM profile WHERE account_login = delete_login;
    DELETE FROM shopping_order WHERE
    shopping_cart_id = (SELECT shopping_cart_id FROM shopping_cart
                        WHERE account_login = delete_login);
    DELETE FROM shopping_cart WHERE account_login = delete_login;
    DELETE FROM account WHERE account_login = delete_login;
    COMMIT;
    END IF;
END;$$;
