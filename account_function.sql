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
    EXECUTE FORMAT('ALTER USER %I CREATEROLE;', user_login);
    COMMIT;
END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_user(old_login VARCHAR(32),
new_password TEXT,
new_login VARCHAR(32) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE login_change VARCHAR(32);
BEGIN
        IF new_login IS NOT NULL AND length(new_login) = 0 THEN
            new_login := NULL;
        END IF;
        login_change := (SELECT COALESCE(new_login,
            (SELECT account_login FROM account
                                  WHERE account_login = old_login)));

        IF new_password IS NOT NULL AND length(new_password)>0 THEN
            new_password := crypt(new_password, gen_salt('bf', 8));
        ELSE
            new_password := NULL;
        END IF;

        UPDATE account SET
    account_login = login_change,
    account_password = COALESCE(new_password, account_password)
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

CREATE OR REPLACE PROCEDURE update_role(user_login VARCHAR(32),
login_change VARCHAR(32),
new_role_id NUMERIC(1))
LANGUAGE plpgsql
AS $$
    DECLARE new_role_name VARCHAR(32);
        old_role_name VARCHAR(32);
BEGIN
    IF new_role_id IS NOT NULL AND
    new_role_id != (SELECT role_id FROM account
                      WHERE account_login = login_change)
    AND (SELECT role_id FROM account
                        WHERE account_login = user_login) = 0 THEN
        new_role_name := (SELECT role_name FROM account_role
        WHERE role_id = new_role_id);
        old_role_name := (SELECT role_name FROM account_role
        JOIN account ON account_role.role_id = account.role_id
        WHERE account_login = login_change);
        IF (SELECT role_id FROM account
                           WHERE account_login = login_change) = 1 THEN
            EXECUTE FORMAT('REVOKE %I FROM %I', old_role_name,
                login_change);
        END IF;
        IF new_role_id < 4 and new_role_id != 2 THEN
            EXECUTE FORMAT('GRANT %I TO %I', new_role_name,
                    login_change);
            UPDATE account SET role_id = new_role_id
            WHERE account_login = login_change;
        END IF;
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE delete_user(delete_login VARCHAR(32))
LANGUAGE plpgsql
AS $$
    DECLARE dlt_member_id VARCHAR(12);
BEGIN
    IF (SELECT COUNT(*) FROM account WHERE account_login = delete_login) THEN
    IF (SELECT role_id FROM account
                                WHERE account_login = delete_login) = 2 THEN
        dlt_member_id := (SELECT member.member_id FROM member
        JOIN member_profile ON member.member_id =
                               member_profile.member_id
        JOIN profile ON member_profile.profile_id = profile.profile_id
                         WHERE account_login = delete_login);
        CALL delete_member(dlt_member_id);
    END IF;
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
