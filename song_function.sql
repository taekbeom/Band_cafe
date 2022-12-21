CREATE OR REPLACE PROCEDURE add_song(set_album_id VARCHAR(12),
new_song_name VARCHAR(128),
new_song_duration NUMERIC(4),
new_song_mv TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE digit_id VARCHAR(12);
        generate_digit_id TEXT;
BEGIN
    IF new_song_mv IS NOT NULL AND length(new_song_mv) = 0 THEN
            new_song_mv := NULL;
        END IF;
    IF (SELECT COUNT(*) FROM album WHERE album_id = set_album_id) > 0 THEN
    generate_digit_id := (SELECT nextval('generate_song_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 12, '0');
    INSERT INTO song
    VALUES (concat('alsg', digit_id), new_song_name,
            new_song_duration, new_song_mv, set_album_id);
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_song(upd_song_id VARCHAR(16),
new_song_name VARCHAR(128) DEFAULT NULL,
new_song_duration NUMERIC(4) DEFAULT NULL,
new_song_mv TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    IF new_song_name IS NOT NULL AND length(new_song_name) = 0 THEN
            new_song_name := NULL;
        END IF;
    IF new_song_mv IS NOT NULL AND length(new_song_mv) = 0 THEN
            new_song_mv := NULL;
        END IF;
    UPDATE song
    SET song_name = COALESCE(new_song_name, song_name),
    song_duration = COALESCE(new_song_duration, song_duration),
    song_mv = new_song_mv
    WHERE song_id = upd_song_id;
END;$$;

CREATE OR REPLACE PROCEDURE delete_song(dlt_song_id VARCHAR(16))
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM song WHERE song_id = dlt_song_id;
END;$$;
