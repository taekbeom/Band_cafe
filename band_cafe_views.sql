CREATE OR REPLACE VIEW song_dur AS
    SELECT (div(song_duration, 60) ||
            ':' || lpad(mod(song_duration, 60)::TEXT, 2, '0'))
    AS song_duration_format
    FROM song;

CREATE OR REPLACE VIEW song_info AS
    SELECT group_name, album_name, album_release_date, song_name,
           (div(song_duration, 60) ||
            ':' || lpad(mod(song_duration, 60)::TEXT, 2, '0'))
    AS song_duration_format, song_mv
    FROM song
    JOIN album ON song.album_id = album.album_id
    JOIN member_group ON album.group_owner_id = member_group.group_id;

SELECT * FROM song_info;