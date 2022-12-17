CREATE OR REPLACE VIEW song_dur AS
    SELECT (div(song_duration, 60) ||
            ':' || lpad(mod(song_duration, 60)::TEXT, 2, '0'))
    AS song_duration_format
    FROM song;