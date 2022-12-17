CREATE OR REPLACE PROCEDURE add_song(set_album_id VARCHAR(12),
new_song_name VARCHAR(128),
new_song_duration NUMERIC(4),
new_song_mv TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
    DECLARE digit_id VARCHAR(12);
        generate_digit_id TEXT;
        unnec INTEGER;
BEGIN
    IF (SELECT COUNT(*) FROM song) > 0 THEN
        unnec := (SELECT setval('generate_12digit_id',
        (SELECT MAX(substring(song_id FROM 5 FOR 12)::INTEGER) FROM song)));
    ELSE
        unnec := (SELECT setval('generate_12digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_12digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 12, '0');

    IF (SELECT COUNT(*) FROM album WHERE album_id = set_album_id) > 0 THEN
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
    UPDATE song
    SET song_name = COALESCE(new_song_name, song_name),
    song_duration = COALESCE(new_song_duration, song_duration),
    song_mv = COALESCE(new_song_mv, song_mv)
    WHERE song_id = upd_song_id;
END;$$;

CREATE OR REPLACE PROCEDURE delete_song(dlt_song_id VARCHAR(16))
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM song WHERE song_id = dlt_song_id;
END;$$;

CREATE OR REPLACE PROCEDURE delete_song_mv(upd_song_id VARCHAR(16))
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE song
    SET song_mv = NULL WHERE song_id = upd_song_id;
END;$$;

CALL add_song('albm00000001', 'dream', 233);
CALL add_song('albm00000003', 'dream', 233, 'dsa');

SELECT * FROM song;

CALL update_song('alsg000000000001', 'funny', 3444, 'hehe');
CALL delete_song('alsg000000001004');
CALL delete_song_mv('alsg000000000001');

DROP PROCEDURE add_song(set_album_id VARCHAR(12),
new_song_name VARCHAR(128),
new_song_duration NUMERIC(4),
new_song_mv TEXT )