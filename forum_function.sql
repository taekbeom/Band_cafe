CREATE OR REPLACE PROCEDURE update_forum(upd_forum_id VARCHAR(10),
new_forum_name TEXT DEFAULT NULL,
new_forum_description VARCHAR(64) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    IF new_forum_name IS NOT NULL AND length(new_forum_name) = 0 THEN
            new_forum_name := NULL;
        END IF;
    IF new_forum_description IS NOT NULL AND length(new_forum_description) = 0 THEN
            new_forum_description := NULL;
        END IF;
    UPDATE forum
    SET forum_name = COALESCE(new_forum_name, forum_name),
    forum_description = COALESCE(new_forum_description, forum_description)
    WHERE forum_id = upd_forum_id;
END;$$;
