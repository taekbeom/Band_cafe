CREATE OR REPLACE PROCEDURE add_member(member_account_login VARCHAR(32),
ref_label_id VARCHAR(10),
ref_group_id VARCHAR(10),
new_member_name VARCHAR(128),
new_member_stage_name VARCHAR(128),
new_member_string_date TEXT,
new_member_country VARCHAR(64),
new_member_city VARCHAR(64),
new_member_description TEXT,
new_member_height NUMERIC(3) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE digit_id VARCHAR(8);
        generate_digit_id TEXT;
        new_member_date DATE;
BEGIN
    IF (SELECT COUNT(*) FROM account WHERE account_login
                                               = member_account_login) = 1
    AND (SELECT role_id FROM account WHERE account_login
                                               = member_account_login) = 3 THEN
        IF new_member_height IS NOT NULL AND new_member_height = 0 THEN
            new_member_height := NULL;
        END IF;
        IF (is_date(new_member_string_date)) THEN
            new_member_date := to_date(new_member_string_date, 'yyyy-mm-dd');
        ELSE
            new_member_date := NULL;
        END IF;
        IF new_member_date IS NOT NULL THEN
            generate_digit_id := (SELECT nextval('generate_member_id'))::TEXT;
            digit_id := lpad(generate_digit_id, 8, '0');
            INSERT INTO member
            VALUES (concat('mmbr', digit_id), new_member_name,
                    new_member_stage_name, new_member_date, new_member_country,
                    new_member_city, new_member_height, new_member_description,
                    ref_label_id, ref_group_id);
            INSERT INTO member_profile
            VALUES (concat('mmbr', digit_id),
                    (SELECT profile_id FROM profile
                                       WHERE account_login = member_account_login));
            EXECUTE FORMAT('GRANT member_role TO %I',
                    member_account_login);
            UPDATE account SET role_id = 2
            WHERE account_login = member_account_login;
            UPDATE profile
            SET profile_date_of_birth = new_member_date
            WHERE account_login = member_account_login;
            COMMIT ;
        END IF;
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE add_member_position(set_member_id VARCHAR(12),
set_member_position_code NUMERIC(2))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO member_position
    VALUES (set_member_id, set_member_position_code);
END;$$;

CREATE OR REPLACE PROCEDURE update_member(upd_member_id VARCHAR(12),
ref_label_id VARCHAR(8) DEFAULT NULL,
ref_group_id VARCHAR(10) DEFAULT NULL,
new_member_name VARCHAR(128) DEFAULT NULL,
new_member_stage_name VARCHAR(128) DEFAULT NULL,
new_member_string_date TEXT DEFAULT NULL,
new_member_country VARCHAR(64) DEFAULT NULL,
new_member_city VARCHAR(64) DEFAULT NULL,
new_member_height NUMERIC(3) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE new_member_date DATE;
BEGIN
        IF new_member_name IS NOT NULL AND length(new_member_name) = 0 THEN
            new_member_name := NULL;
        END IF;
        IF new_member_stage_name IS NOT NULL AND length(new_member_stage_name) = 0 THEN
            new_member_stage_name := NULL;
        END IF;
        IF new_member_country IS NOT NULL AND length(new_member_country) = 0 THEN
            new_member_country := NULL;
        END IF;
        IF new_member_city IS NOT NULL AND length(new_member_city) = 0 THEN
            new_member_city := NULL;
        END IF;
        IF new_member_height IS NOT NULL AND new_member_height = 0 THEN
            new_member_height := NULL;
        END IF;
        IF (SELECT COUNT(*) FROM group_label WHERE label_id = ref_label_id) = 0 THEN
            ref_label_id = NULL;
        END IF;
        IF (SELECT COUNT(*) FROM member_group WHERE group_id = ref_group_id) = 0 THEN
            ref_group_id = NULL;
        END IF;
        IF (is_date(new_member_string_date)) THEN
            new_member_date := to_date(new_member_string_date, 'yyyy-mm-dd');
        ELSE
            new_member_date := NULL;
        END IF;
        UPDATE member
        SET member_name = COALESCE(new_member_name, member_name),
        member_stage_name = COALESCE(new_member_stage_name, member_stage_name),
        member_date_of_birth = COALESCE(new_member_date, member_date_of_birth),
        member_country = COALESCE(new_member_country, member_country),
        member_city = COALESCE(new_member_city, member_city),
        member_height = COALESCE(new_member_height, member_height),
        label_id = COALESCE(ref_label_id, label_id),
        group_id = COALESCE(ref_group_id, group_id)
        WHERE member_id = upd_member_id;
        UPDATE profile
        SET profile_date_of_birth = COALESCE(new_member_date,
            profile_date_of_birth)
        WHERE account_login = (SELECT account_login FROM profile
                            JOIN member_profile ON profile.profile_id
                                                       = member_profile.profile_id
                             WHERE member_id = upd_member_id);
END;$$;

CREATE OR REPLACE PROCEDURE delete_member(dlt_member_id VARCHAR(12))
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE FORMAT('REVOKE member_role FROM %I',
        (SELECT account_login FROM profile
    JOIN member_profile ON profile.profile_id =
                           member_profile.profile_id
    WHERE member_id = dlt_member_id));
    UPDATE account
    SET role_id = 3
    WHERE account_login = (SELECT account_login FROM profile
    JOIN member_profile ON profile.profile_id =
                           member_profile.profile_id
    WHERE member_id = dlt_member_id);
    DELETE FROM member_profile
    WHERE member_id = dlt_member_id;
    DELETE FROM member_position
    WHERE member_id = dlt_member_id;
    DELETE FROM member
    WHERE member_id = dlt_member_id;
    COMMIT;
END;$$;

CREATE OR REPLACE PROCEDURE delete_member_position(set_member_id VARCHAR(12),
set_member_position_code NUMERIC(2))
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM member_position
    WHERE member_id = set_member_id AND
          position_code = set_member_position_code;
END;$$;
