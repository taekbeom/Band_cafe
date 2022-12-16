CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE OR REPLACE PROCEDURE add_post(set_forum_id VARCHAR(10),
set_author_login VARCHAR(32),
new_post_text TEXT,
new_post_image TEXT DEFAULT NULL,
new_reply_post_id VARCHAR(32) DEFAULT NULL,
new_category_id NUMERIC(2) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT COUNT(*) FROM forum
                        WHERE forum_id = set_forum_id) > 0
    AND (SELECT COUNT(*) FROM account
                         WHERE account_login = set_author_login) > 0
    AND (new_post_text IS NOT NULL)
    AND ((SELECT COUNT(*) FROM post
                          WHERE post_id = new_reply_post_id) > 0
             AND new_category_id IS NULL
             OR
         (new_reply_post_id IS NULL AND
          (new_category_id IS NULL OR
           (SELECT COUNT(*) FROM post_category
                          WHERE category_id = new_category_id) > 0))
         )
        THEN
        INSERT INTO post
        VALUES (replace((SELECT uuid_generate_v4())::TEXT,'-',''), new_post_text,
                CURRENT_DATE, new_post_image, set_forum_id,
                set_author_login, new_reply_post_id,
                new_category_id);
    END IF;
END;$$;

CREATE OR REPLACE FUNCTION delete_author()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE post
    SET author_login = NULL WHERE author_login = OLD.account_login;
    RETURN OLD;
END;$$;

CREATE OR REPLACE TRIGGER delete_author_trigger
BEFORE DELETE ON account
FOR EACH ROW
EXECUTE FUNCTION delete_author();



CALL add_post('fr00010001', 'oleshandra',
    'asfsa');
CALL add_post('fr00010001', 'oleshandra',
    'asfsa', null, null, 1);

CALL add_post('fr00010001', 'oleshandra',
    'asfsa', null, '25dda4de42d141a0aae2e7a20c9177a1');

DROP TRIGGER delete_author_trigger ON account;
DROP FUNCTION delete_author();

SELECT * FROM post;
DELETE FROM post;

DROP PROCEDURE add_post(set_forum_id VARCHAR(10),
set_author_login VARCHAR(32),
new_post_text TEXT,
new_post_image TEXT,
new_reply_post_id VARCHAR(32),
new_category_id NUMERIC(2))