CREATE OR REPLACE FUNCTION add_forum()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    DECLARE set_group_id VARCHAR(10);
        set_group_name VARCHAR(128);
        digit_id VARCHAR(4);
        generate_digit_id TEXT;
        unnec INTEGER;
BEGIN
    IF (SELECT COUNT(*) FROM forum) > 0 THEN
        unnec := (SELECT setval('generate_4digit_id',
                                (SELECT MAX(substring(forum_id FROM 7 FOR 4)::INTEGER) FROM forum)));
    ELSE
        unnec := (SELECT setval('generate_4digit_id', 1, FALSE));
    END IF;
    generate_digit_id := (SELECT nextval('generate_4digit_id'))::TEXT;
    digit_id := lpad(generate_digit_id, 4, '0');
    set_group_id := (SELECT member_group.group_id FROM member_group
    LEFT JOIN forum ON member_group.group_id = forum.group_id
    WHERE forum.group_id IS NULL LIMIT 1);
    set_group_name := (SELECT group_name FROM member_group
    WHERE group_id = set_group_id);
    INSERT INTO forum
    VALUES (concat('fr', substring(set_group_id FROM 7 FOR 4), digit_id),
            concat(set_group_name, '''s FORUM'),
            concat('Hello, it''s ', set_group_name),
            set_group_id);
    RETURN NULL;
END;$$;

CREATE OR REPLACE TRIGGER add_forum_trigger
    AFTER INSERT ON member_group
    FOR EACH ROW
    EXECUTE FUNCTION add_forum();

CREATE OR REPLACE PROCEDURE update_forum(upd_forum_id VARCHAR(10),
new_forum_name TEXT DEFAULT NULL,
new_forum_description VARCHAR(64) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE forum
    SET forum_name = COALESCE(new_forum_name, forum_name),
    forum_description = COALESCE(new_forum_description, forum_description)
    WHERE forum_id = upd_forum_id;
END;$$;


CALL update_forum('fr00010001', NULL, 'konnichiwa');

SELECT * FROM forum;
DELETE FROM forum;

DROP FUNCTION update_forum(upd_forum_id VARCHAR(10),
new_forum_name TEXT,
new_forum_description VARCHAR(64))