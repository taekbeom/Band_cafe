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


CREATE OR REPLACE VIEW merch_info AS
    SELECT merch_id, merch_name, merch_price,
           merch_status, merch_description_source,
           group_name, group_fandom_name
    FROM merch m
        JOIN member_group mg ON m.group_id = mg.group_id;

CREATE OR REPLACE VIEW order_info AS
    SELECT account_login, order_id, order_add_date,
           order_status, confirm_payment, order_address,
       order_amount, so.merch_id, merch_name, merch_status,
       ((merch_price*order_amount) :: NUMERIC(12,2)) AS
           total_price, merch_description_source
    FROM shopping_order so
        JOIN merch mg ON so.merch_id = mg.merch_id
        JOIN shopping_cart sc on so.shopping_cart_id = sc.shopping_cart_id;
