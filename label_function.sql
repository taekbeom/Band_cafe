CREATE OR REPLACE FUNCTION add_label(new_label_name VARCHAR(128),
new_label_director VARCHAR(128),
new_label_country VARCHAR(64),
new_label_city VARCHAR(64),
new_label_main_address TEXT,
new_label_string_date TEXT,
new_label_description TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
    DECLARE new_label_id_country VARCHAR(64);
        digit_id VARCHAR(4);
        generate_digit_id TEXT;
        new_label_date DATE;
        unnec INTEGER;
BEGIN
    IF (SELECT COUNT(*) FROM group_label) > 0 THEN
        unnec := (SELECT setval('generate_4digit_id', (SELECT MAX(substring(label_id FROM 3 FOR 4)::INTEGER) FROM group_label)));
    ELSE
        unnec := (SELECT setval('generate_4digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_4digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 4, '0');
    new_label_id_country := new_label_country;
    IF split_part(new_label_country, ' ', 2) != '' THEN
        new_label_id_country := split_part(new_label_country, ' ', 2);
    END IF;
    IF (is_date(new_label_string_date) AND
        to_date(new_label_string_date, 'yyyy-mm-dd') IS NOT NULL) THEN
        new_label_date := to_date(new_label_string_date, 'yyyy-mm-dd');
    ELSE
        RETURN FALSE;
    END IF;
    INSERT INTO group_label
    VALUES (concat('lb', digit_id, substring(upper(new_label_id_country) FROM 1 FOR 2)),
            new_label_name, new_label_director, new_label_country,
            new_label_city, new_label_main_address, new_label_date,
            new_label_description);
    RETURN TRUE;
END;$$;

CREATE OR REPLACE FUNCTION update_label(upd_label_id VARCHAR(8),
new_label_name VARCHAR(128) DEFAULT NULL,
new_label_director VARCHAR(128) DEFAULT NULL,
new_label_country VARCHAR(64) DEFAULT NULL,
new_label_city VARCHAR(64) DEFAULT NULL,
new_label_address TEXT DEFAULT NULL,
new_label_description TEXT DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
    DECLARE new_label_id_country VARCHAR(64);
BEGIN
    UPDATE group_label SET
    label_name = COALESCE(new_label_name, label_name),
    label_director = COALESCE(new_label_director, label_director),
    label_country = COALESCE(new_label_country, label_country),
    label_city = COALESCE(new_label_city, label_city),
    label_main_address = COALESCE(new_label_address, label_main_address),
    label_description_source = COALESCE(new_label_description, label_description_source)
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
    RETURN TRUE;
END;$$;

SELECT * FROM add_label('JYP', 'J Y Park', 'South Korea', 'Seoul', 'asfsa', '2010-04-03', 'sada');
SELECT * FROM group_label
DELETE FROM group_label;

SELECT update_label('lb0002KO', 'SM', 'bp', 'JAPAN');

DROP FUNCTION add_label(new_label_name VARCHAR(128),
new_label_director VARCHAR(128),
new_label_country VARCHAR(64),
new_label_city VARCHAR(64),
new_label_main_address TEXT,
new_label_string_date TEXT,
new_label_description TEXT);

DROP FUNCTION update_label(upd_label_id VARCHAR(8),
new_label_name VARCHAR(128),
new_label_director VARCHAR(128),
new_label_country VARCHAR(64),
new_label_city VARCHAR(64),
new_label_address TEXT,
new_label_description TEXT);

SELECT ((SELECT substring(label_id FROM 3 FOR 4) FROM group_label)::INTEGER)

