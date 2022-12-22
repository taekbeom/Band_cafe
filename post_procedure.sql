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
    IF new_reply_post_id IS NOT NULL AND length(new_reply_post_id) = 0 THEN
            new_reply_post_id := NULL;
        END IF;
    IF (SELECT COUNT(*) FROM forum
                        WHERE forum_id = set_forum_id) > 0
    AND (SELECT COUNT(*) FROM account
                         WHERE account_login = set_author_login) > 0
    AND (new_post_text IS NOT NULL)
    AND ((SELECT COUNT(*) FROM post
                          WHERE post_id = new_reply_post_id
                          AND forum_id = set_forum_id) > 0
             AND new_category_id IS NULL
             OR
         (new_reply_post_id IS NULL AND
          (new_category_id IS NULL OR
           (SELECT COUNT(*) FROM post_category
                          WHERE category_id = new_category_id) > 0)
             AND (SELECT COUNT(*) FROM profile
                JOIN member_profile ON
                    profile.profile_id = member_profile.profile_id
                JOIN member ON
                    member_profile.member_id = member.member_id
                JOIN forum ON
                    member.group_id = forum.group_id
                WHERE profile.account_login = set_author_login
                AND forum.forum_id = set_forum_id) > 0)
         )
        THEN
        INSERT INTO post
        VALUES (replace((SELECT uuid_generate_v4())::TEXT,'-',''), new_post_text,
                CURRENT_DATE, new_post_image, set_forum_id,
                set_author_login, new_reply_post_id,
                new_category_id);
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_post(upd_post_id VARCHAR(32),
new_post_text TEXT DEFAULT NULL,
new_post_image TEXT DEFAULT NULL,
new_category_id NUMERIC(2) DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    IF new_post_text IS NOT NULL AND length(new_post_text) = 0 THEN
            new_post_text := NULL;
        END IF;
    IF (new_category_id IS NULL) THEN
        new_category_id := (SELECT category_id FROM post
        WHERE post_id = upd_post_id);
    END IF;
    IF (SELECT reply_post_id FROM post
                             WHERE post_id = upd_post_id) IS NOT NULL THEN
        new_category_id := NULL;
    END IF;
    IF (SELECT COUNT(*) FROM post_category
                        WHERE category_id = new_category_id) = 1
        OR new_category_id IS NULL THEN
        UPDATE post
        SET post_text = COALESCE(new_post_text, post_text),
            post_image_source = COALESCE(new_post_image, post_image_source),
            category_id = new_category_id
        WHERE post_id = upd_post_id;
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE delete_post(dlt_post_id VARCHAR(32),
dlt_author_login VARCHAR(32))
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT COUNT(*) FROM post WHERE author_login = dlt_author_login
                        AND post_id = dlt_post_id) = 1 THEN
    IF (SELECT reply_post_id FROM post
                             WHERE post_id = dlt_post_id) IS NULL THEN
        DELETE FROM post WHERE reply_post_id = dlt_post_id;
        DELETE FROM post WHERE post_id = dlt_post_id;
    ELSIF (SELECT COUNT(*) FROM post
    WHERE reply_post_id = dlt_post_id) = 0 THEN
        DELETE FROM post WHERE post_id = dlt_post_id;
    ELSE
        UPDATE post
        SET post_text = 'Cообщение удалено',
        post_image_source = NULL
        WHERE post_id = dlt_post_id;
    END IF;
    END IF;
END;$$;
