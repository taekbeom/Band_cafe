CREATE OR REPLACE PROCEDURE add_group(new_group_name VARCHAR(128),
                                     new_group_country VARCHAR(64),
                                     new_group_debut TEXT,
                                     new_group_fandom_name VARCHAR(128),
                                     new_group_description TEXT,
                                     manager_login VARCHAR(32),
                                     set_label_id VARCHAR(8),
                                     new_group_disband TEXT DEFAULT NULL)
    LANGUAGE plpgsql
AS
$$
DECLARE
    digit_id             VARCHAR(4);
    generate_digit_id    TEXT;
    unnec                INTEGER;
    new_group_debut_date DATE;
    new_group_disband_date DATE;
BEGIN
    IF (SELECT COUNT(*) FROM group_label
                        WHERE group_label.label_id = set_label_id) THEN
        IF (SELECT COUNT(*) FROM member_group
            WHERE substring(group_id FROM 3 FOR 4) = substring(set_label_id FROM 3 FOR 4)) > 0 THEN
            unnec := (SELECT setval('generate_4digit_id',
            (SELECT MAX(substring(group_id FROM 7 FOR 4)::INTEGER) FROM member_group
            WHERE substring(group_id FROM 3 FOR 4) = substring(set_label_id FROM 3 FOR 4))));
        ELSE
            unnec := (SELECT setval('generate_4digit_id', 1, FALSE));
        END IF;
        generate_digit_id := (SELECT nextval('generate_4digit_id'))::TEXT;
        digit_id := lpad(generate_digit_id, 4, '0');
        IF (is_date(new_group_debut) AND
            to_date(new_group_debut, 'yyyy-mm-dd') IS NOT NULL) THEN
            new_group_debut_date := to_date(new_group_debut, 'yyyy-mm-dd');
            ELSE
            new_group_debut_date := NULL;
        END IF;
        IF (is_date(new_group_disband)) THEN
            new_group_disband_date := to_date(new_group_disband, 'yyyy-mm-dd');
        ELSE
            new_group_disband_date := NULL;
        END IF;
        IF (SELECT COUNT(*) FROM account
                            WHERE account_login = manager_login) = 1
            AND new_group_debut_date IS NOT NULL THEN
            INSERT INTO member_group
        VALUES (concat('gr', substring(set_label_id FROM 3 FOR 4), digit_id),
                new_group_name, new_group_country, new_group_debut_date,
                new_group_disband_date, new_group_fandom_name,
                new_group_description, manager_login);
        END IF;
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_group(upd_group_id VARCHAR(10),
new_group_name VARCHAR(128) DEFAULT NULL,
new_group_fandom_name VARCHAR(128) DEFAULT NULL,
new_group_description TEXT DEFAULT NULL,
manager_login VARCHAR(32) DEFAULT NULL,
new_label_id VARCHAR(8) DEFAULT NULL,
new_group_disband TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
DECLARE new_group_disband_date DATE;
    digit_id             VARCHAR(4);
    generate_digit_id    TEXT;
    unnec                INTEGER;
BEGIN
        IF (is_date(new_group_disband)) THEN
            new_group_disband_date := to_date(new_group_disband, 'yyyy-mm-dd');
        ELSE
            new_group_disband_date := NULL;
        END IF;
        IF (manager_login IS NOT NULL) AND
           (SELECT COUNT(*) FROM account
                            WHERE account_login = manager_login) = 0 THEN
            manager_login := NULL;
        END IF;
    UPDATE member_group SET
    group_name = COALESCE(new_group_name, group_name),
    group_fandom_name = COALESCE(new_group_fandom_name, group_fandom_name),
    group_description_source = COALESCE(new_group_description, group_description_source),
    group_manager = COALESCE(manager_login, group_manager),
    group_disband_date = COALESCE(new_group_disband_date, group_disband_date)
    WHERE group_id = upd_group_id;
    IF (new_label_id IS NOT NULL)
           AND (SELECT COUNT(*) FROM group_label
                                WHERE label_id = new_label_id) = 1 THEN
        IF (SELECT COUNT(*) FROM member_group
        WHERE substring(group_id FROM 3 FOR 4) = substring(new_label_id FROM 3 FOR 4)) > 0 THEN
        unnec := (SELECT setval('generate_4digit_id',
        (SELECT MAX(substring(group_id FROM 7 FOR 4)::INTEGER) FROM member_group
        WHERE substring(group_id FROM 3 FOR 4) = substring(new_label_id FROM 3 FOR 4))));
    ELSE
        unnec := (SELECT setval('generate_4digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_4digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 4, '0');
        UPDATE member_group
        SET group_id = concat('gr',
            substring(new_label_id FROM 3 FOR 4),
            digit_id)
        WHERE group_id = upd_group_id;
    END IF;
END;$$;
