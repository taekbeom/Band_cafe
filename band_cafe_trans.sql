BEGIN;
DO LANGUAGE plpgsql
$$
    DECLARE set_group_id VARCHAR(10);
    set_forum_id VARCHAR(10);
BEGIN
    IF (SELECT COUNT(*) FROM account WHERE account_login = CURRENT_USER) = 0
    THEN
        RAISE NOTICE 'You do not belong here';
    ELSE
    set_group_id := CONCAT('gr',
        lpad((COALESCE((SELECT MAX(substring(group_id FROM 3 FOR 8)::INTEGER)
                        FROM member_group) + 1, 1)::TEXT),
            8, '0'));
    set_forum_id := CONCAT('fr',
        lpad((COALESCE((SELECT MAX(substring(forum_id FROM 3 FOR 8)::INTEGER)
                        FROM forum) + 1, 1)::TEXT),
            8, '0'));
    IF (SELECT role_id FROM account WHERE account_login = CURRENT_USER) != 1 THEN
        RAISE NOTICE 'You do not have rights';
    ELSE
    INSERT INTO member_group
    VALUES (set_group_id, 'somename', 'somecountry',
            CURRENT_DATE, NULL, 'somefandname', 'somedesc.txt',
            CURRENT_USER);
    CREATE TEMP TABLE forum_test(
    forum_id VARCHAR(10),
    forum_name TEXT,
    forum_description VARCHAR(64),
    group_id VARCHAR(10));
    INSERT INTO forum_test
    SELECT * FROM forum WHERE group_id = set_group_id;
    IF (SELECT forum_id FROM forum_test) = set_forum_id
    AND (SELECT forum_name FROM forum_test) = 'somename''s FORUM'
    AND (SELECT forum_description FROM forum_test) = 'Hello, it''s somename'
    AND (SELECT group_id FROM forum_test) = set_group_id
    THEN
        RAISE NOTICE 'Check complete';
    ELSE
        RAISE NOTICE 'Check failed';
    END IF;
    PERFORM setval('generate_forum_id',
        (substring(set_forum_id FROM 3 FOR 8)::INTEGER), FALSE);
    END IF;
    END IF;
END;$$;
ROLLBACK;