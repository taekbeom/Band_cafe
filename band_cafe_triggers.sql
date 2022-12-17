CREATE OR REPLACE FUNCTION add_forum()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE set_group_name VARCHAR(128);
        digit_id VARCHAR(4);
        generate_digit_id TEXT;
        unnec INTEGER;
BEGIN
    IF (SELECT COUNT(*) FROM forum
    WHERE substring(forum_id FROM 3 FOR 4) = substring(NEW.group_id FROM 7 FOR 4)) > 0 THEN
        unnec := (SELECT setval('generate_4digit_id',
        (SELECT MAX(substring(forum_id FROM 7 FOR 4)::INTEGER) FROM forum
        WHERE substring(forum_id FROM 3 FOR 4) = substring(NEW.group_id FROM 7 FOR 4))));
    ELSE
        unnec := (SELECT setval('generate_4digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_4digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 4, '0');
    set_group_name := (SELECT group_name FROM member_group
    WHERE group_id = NEW.group_id);
    INSERT INTO forum
    VALUES (concat('fr', substring(NEW.group_id FROM 7 FOR 4), digit_id),
            concat(set_group_name, '''s FORUM'),
            concat('Hello, it''s ', set_group_name),
            NEW.group_id);
    RETURN NULL;
END;$$;

CREATE OR REPLACE TRIGGER add_forum_trigger
    AFTER INSERT ON member_group
    FOR EACH ROW
    EXECUTE FUNCTION add_forum();

CREATE OR REPLACE FUNCTION update_forum_id()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE upd_group_id VARCHAR(10);
        digit_id VARCHAR(4);
        generate_digit_id TEXT;
        unnec INTEGER;
BEGIN
        upd_group_id := (SELECT group_id FROM forum
        WHERE substring(forum_id FROM 3 FOR 4) != substring(group_id FROM 7 FOR 4));
    IF (SELECT COUNT(*) FROM forum
    WHERE substring(forum_id FROM 3 FOR 4) = substring(upd_group_id FROM 7 FOR 4)) > 0 THEN
        unnec := (SELECT setval('generate_4digit_id',
        (SELECT MAX(substring(forum_id FROM 7 FOR 4)::INTEGER) FROM forum
        WHERE substring(forum_id FROM 3 FOR 4) = substring(upd_group_id FROM 7 FOR 4))));
    ELSE
        unnec := (SELECT setval('generate_4digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_4digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 4, '0');
    UPDATE forum
    SET forum_id = concat('fr', substring(upd_group_id FROM 7 FOR 4),
        digit_id)
    WHERE group_id = upd_group_id;
    RETURN NEW;
END;$$;

CREATE OR REPLACE TRIGGER update_forum_id_trigger
    AFTER UPDATE ON member_group
    FOR EACH ROW
    EXECUTE FUNCTION update_forum_id();


CREATE OR REPLACE FUNCTION delete_author()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE post
    SET author_login = NULL WHERE author_login = OLD.account_login;
    RETURN OLD;
END;$$;

CREATE OR REPLACE TRIGGER delete_author_trigger
BEFORE DELETE ON account
FOR EACH ROW
EXECUTE FUNCTION delete_author();

CREATE OR REPLACE FUNCTION add_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE generate_digit_id TEXT;
    digit_id VARCHAR(8);
    unnec INTEGER;
BEGIN
    IF (SELECT COUNT(*) FROM profile) > 0 THEN
        unnec := (SELECT setval('generate_8digit_id',
            (SELECT MAX(substring(profile_id FROM 3 FOR 8)::INTEGER) FROM profile)));
    ELSE
        unnec := (SELECT setval('generate_8digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_8digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 8, '0');
    INSERT INTO profile(profile_id, account_login)
    VALUES (concat('id', digit_id), NEW.account_login);
    RETURN NULL;
END;$$;

CREATE OR REPLACE TRIGGER add_profile_trigger
AFTER INSERT ON account
FOR EACH ROW
EXECUTE FUNCTION add_profile();

CREATE OR REPLACE FUNCTION add_shopping_cart()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE generate_digit_id TEXT;
    digit_id VARCHAR(8);
    unnec INTEGER;
BEGIN
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
    VALUES (concat('sc', digit_id), FALSE, NEW.account_login);
    RETURN NULL;
END;$$;

CREATE OR REPLACE TRIGGER add_shopping_cart_trigger
AFTER INSERT ON account
FOR EACH ROW
EXECUTE FUNCTION add_shopping_cart();
