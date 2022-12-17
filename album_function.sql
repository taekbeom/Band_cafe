CREATE OR REPLACE PROCEDURE add_album(set_group_id VARCHAR(10),
new_album_name VARCHAR(128),
new_album_release TEXT,
new_album_cover TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE digit_id VARCHAR(8);
        generate_digit_id TEXT;
        new_album_release_date DATE;
        unnec INTEGER;
BEGIN
    IF (SELECT COUNT(*) FROM album) > 0 THEN
        unnec := (SELECT setval('generate_8digit_id',
        (SELECT MAX(substring(album_id FROM 5 FOR 8)::INTEGER) FROM album)));
    ELSE
        unnec := (SELECT setval('generate_8digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_8digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 8, '0');

    IF (is_date(new_album_release) AND
        to_date(new_album_release, 'yyyy-mm-dd') IS NOT NULL) THEN
        new_album_release_date := to_date(new_album_release, 'yyyy-mm-dd');
    ELSE
        new_album_release_date := NULL;
    END IF;

    IF (new_album_release_date IS NOT NULL) AND
       (SELECT COUNT(*) FROM member_group WHERE group_id = set_group_id) > 0 THEN
        INSERT INTO album
        VALUES (concat('albm', digit_id),
                new_album_name, new_album_release_date,
                new_album_cover, set_group_id);
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_album(upd_album_id VARCHAR(12),
new_album_name VARCHAR(128) DEFAULT NULL,
new_album_release TEXT DEFAULT NULL,
new_album_cover TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE new_album_release_date DATE;
BEGIN
    IF (is_date(new_album_release)) THEN
        new_album_release_date := to_date(new_album_release, 'yyyy-mm-dd');
    ELSE
        new_album_release_date := NULL;
    END IF;
    UPDATE album
    SET album_name = COALESCE(new_album_name, album_name),
    album_release_date = COALESCE(new_album_release_date, album_release_date),
    album_cover = new_album_cover
    WHERE album_id = upd_album_id;
END;$$;

CREATE OR REPLACE PROCEDURE delete_album(dlt_album_id VARCHAR(12))
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM album WHERE album_id = dlt_album_id;
END;$$;
