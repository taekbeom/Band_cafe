CREATE OR REPLACE PROCEDURE add_merch(manager_login VARCHAR(32),
new_merch_name TEXT,
new_merch_price NUMERIC(12, 2),
new_merch_amount INTEGER,
new_merch_description TEXT,
set_group_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
    DECLARE digit_id VARCHAR(8);
        generate_digit_id TEXT;
BEGIN
    IF (SELECT group_manager FROM member_group
        WHERE group_id = set_group_id) = manager_login THEN
            generate_digit_id := (SELECT nextval('generate_merch_id'))::TEXT;
            digit_id := lpad(generate_digit_id, 8, '0');
        INSERT INTO merch(merch_id, merch_name, merch_price, merch_amount,
                          merch_description_source, group_id)
        VALUES (concat('mrch', digit_id), new_merch_name,
                new_merch_price, new_merch_amount,
                new_merch_description, set_group_id);
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_merch(upd_merch_id VARCHAR(12),
new_merch_name TEXT DEFAULT NULL,
new_merch_price NUMERIC(12, 2) DEFAULT NULL,
new_merch_status BOOLEAN DEFAULT NULL,
new_merch_amount INTEGER DEFAULT NULL,
new_merch_description TEXT DEFAULT NULL,
new_merch_group_id VARCHAR(10) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE manager_login VARCHAR(32);
BEGIN
        manager_login := (SELECT group_manager FROM member_group
                        JOIN merch ON member_group.group_id = merch.group_id
                        WHERE merch_id = upd_merch_id);
    IF new_merch_group_id IS NULL OR
       (SELECT group_manager FROM member_group
        WHERE group_id = new_merch_group_id) = manager_login THEN
            UPDATE merch
            SET merch_name = COALESCE(new_merch_name, merch_name),
            merch_price = COALESCE(new_merch_price, merch_price),
            merch_status = COALESCE(new_merch_status, merch_status),
            merch_amount = COALESCE(new_merch_amount, merch_amount),
            merch_description_source =
                COALESCE(new_merch_description, merch_description_source),
            group_id = COALESCE(new_merch_group_id, group_id)
            WHERE merch_id = upd_merch_id;
    END IF;
END;$$;
