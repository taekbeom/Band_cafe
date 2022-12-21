CREATE OR REPLACE PROCEDURE add_label(new_label_name VARCHAR(128),
new_label_director VARCHAR(128),
new_label_country VARCHAR(64),
new_label_city VARCHAR(64),
new_label_main_address TEXT,
new_label_string_date TEXT,
new_label_description TEXT)
LANGUAGE plpgsql
AS $$
    DECLARE new_label_id_country VARCHAR(64);
        digit_id VARCHAR(4);
        generate_digit_id TEXT;
        new_label_date DATE;
BEGIN
    new_label_id_country := new_label_country;
    IF split_part(new_label_country, ' ', 2) != '' THEN
        new_label_id_country := split_part(new_label_country, ' ', 2);
    END IF;
    IF (is_date(new_label_string_date) AND
        to_date(new_label_string_date, 'yyyy-mm-dd') IS NOT NULL) THEN
        new_label_date := to_date(new_label_string_date, 'yyyy-mm-dd');
        generate_digit_id := (SELECT nextval('generate_label_id'))::TEXT;
        digit_id := lpad(generate_digit_id, 4, '0');
        INSERT INTO group_label
    VALUES (concat('lb', digit_id, substring(upper(new_label_id_country) FROM 1 FOR 2)),
            new_label_name, new_label_director, new_label_country,
            new_label_city, new_label_main_address, new_label_date,
            new_label_description);
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_label(upd_label_id VARCHAR(8),
new_label_name VARCHAR(128) DEFAULT NULL,
new_label_director VARCHAR(128) DEFAULT NULL,
new_label_country VARCHAR(64) DEFAULT NULL,
new_label_city VARCHAR(64) DEFAULT NULL,
new_label_address TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE new_label_id_country VARCHAR(64);
BEGIN
    IF new_label_name IS NOT NULL AND length(new_label_name) = 0 THEN
            new_label_name := NULL;
        END IF;
    IF new_label_director IS NOT NULL AND length(new_label_director) = 0 THEN
            new_label_director := NULL;
        END IF;
    IF new_label_city IS NOT NULL AND length(new_label_city) = 0 THEN
            new_label_city := NULL;
        END IF;
    IF new_label_address IS NOT NULL AND length(new_label_address) = 0 THEN
            new_label_address := NULL;
        END IF;
    UPDATE group_label SET
    label_name = COALESCE(new_label_name, label_name),
    label_director = COALESCE(new_label_director, label_director),
    label_country = COALESCE(new_label_country, label_country),
    label_city = COALESCE(new_label_city, label_city),
    label_main_address = COALESCE(new_label_address, label_main_address)
    WHERE label_id = upd_label_id;
    IF new_label_country IS NOT NULL THEN
    new_label_id_country := new_label_country;
    IF split_part(new_label_country, ' ', 2) != '' THEN
        new_label_id_country := split_part(new_label_country, ' ', 2);
    END IF;
    UPDATE group_label
    SET label_id = concat('lb', substring(upd_label_id FROM 3 FOR 4),
        upper(substring(new_label_id_country FROM 1 FOR 2)))
    WHERE label_id = upd_label_id;
    END IF;
    COMMIT;
END;$$;
