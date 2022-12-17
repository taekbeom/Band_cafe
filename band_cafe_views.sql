CREATE OR REPLACE VIEW song_dur AS
    SELECT (div(song_duration, 60) ||
            ':' || mod(song_duration, 60))
    AS song_duration_format
    FROM song;