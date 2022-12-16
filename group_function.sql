CREATE OR REPLACE FUNCTION add_group(new_group_name VARCHAR(128),
                                     new_group_country VARCHAR(64),
                                     new_group_debut TEXT,
                                     new_group_fandom_name VARCHAR(128),
                                     new_group_description TEXT,
                                     manager_login VARCHAR(32),
                                     label_id VARCHAR(8),
                                     new_group_disband TEXT DEFAULT NULL)
    RETURNS BOOLEAN
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
    IF (SELECT COUNT(*) FROM member_group) > 0 THEN
        unnec := (SELECT setval('generate_4digit_id',
                                (SELECT MAX(substring(group_id FROM 7 FOR 4)::INTEGER) FROM member_group)));
    ELSE
        unnec := (SELECT setval('generate_4digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_4digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 4, '0');
    IF (is_date(new_group_debut) AND
        to_date(new_group_debut, 'yyyy-mm-dd') IS NOT NULL) THEN
        new_group_debut_date := to_date(new_group_debut, 'yyyy-mm-dd');
    ELSE
        RETURN FALSE;
    END IF;
    IF (is_date(new_group_disband)) THEN
        new_group_disband_date := to_date(new_group_disband, 'yyyy-mm-dd');
    ELSE
        RETURN FALSE;
    END IF;
    IF (SELECT COUNT(*) FROM account
                        WHERE account_login = manager_login) = 0 THEN
        RETURN FALSE;
    END IF;
    INSERT INTO member_group
    VALUES (concat('gr', substring(label_id FROM 3 FOR 4), digit_id),
            new_group_name, new_group_country, new_group_debut_date,
            new_group_disband_date, new_group_fandom_name,
            new_group_description, manager_login);
    RETURN TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION update_group(upd_group_id VARCHAR(10),
new_group_name VARCHAR(128) DEFAULT NULL,
new_group_fandom_name VARCHAR(128) DEFAULT NULL,
new_group_description TEXT DEFAULT NULL,
manager_login VARCHAR(32) DEFAULT NULL,
new_label_id VARCHAR(8) DEFAULT NULL,
new_group_disband TEXT DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE new_group_disband_date DATE;
BEGIN
        IF (is_date(new_group_disband)) THEN
            new_group_disband_date := to_date(new_group_disband, 'yyyy-mm-dd');
        ELSE
            RETURN FALSE;
        END IF;
        IF (manager_login IS NOT NULL) AND
           (SELECT COUNT(*) FROM account
                            WHERE account_login = manager_login) = 0 THEN
            RETURN FALSE;
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
        UPDATE member_group
        SET group_id = concat('gr',
            substring(new_label_id FROM 3 FOR 4),
            substring(upd_group_id FROM 7 FOR 4))
        WHERE group_id = upd_group_id;
    END IF;
    RETURN TRUE;
END;$$;


SELECT add_group('fafa', 'dassda', '2020-01-01', 'adsa', 'das', 'oleshandra', 'lb0001KO');
SELECT update_group('gr00010001', 'ar', null, null, 'olleg', 'lb0002KO', '2022-03-03');

SELECT * FROM member_group;
DELETE FROM member_group;


DROP FUNCTION add_group(new_group_name VARCHAR(128),
                                     new_group_country VARCHAR(64),
                                     new_group_debut TEXT,
                                     new_group_fandom_name VARCHAR(128),
                                     new_group_description TEXT,
                                     manager_login VARCHAR(32),
                                     label_id VARCHAR(8),
                                     new_group_disband TEXT);

DROP FUNCTION update_group(upd_group_id VARCHAR(10),
new_group_name VARCHAR(128),
new_group_fandom_name VARCHAR(128),
new_group_description TEXT,
manager_login VARCHAR(32),
new_label_id VARCHAR(8),
new_group_disband TEXT);