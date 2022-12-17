CREATE ROLE user_role;
CREATE ROLE member_role;
CREATE ROLE manager_role;
CREATE ROLE admin_role;

INSERT INTO account
VALUES ('olleg', crypt('HF*w3hI9ZWL7JBoRy243&#ohV5YI9Zp', gen_salt('bf', 8)), 0);
CREATE USER olleg WITH PASSWORD 'HF*w3hI9ZWL7JBoRy243&#ohV5YI9Zp';
GRANT admin_role TO olleg;
ALTER ROLE admin_role CREATEROLE;
ALTER USER olleg CREATEROLE;
GRANT pg_write_server_files TO olleg;

GRANT USAGE, SELECT, UPDATE ON SEQUENCE generate_4digit_id
    TO admin_role, manager_role, member_role, user_role;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE generate_8digit_id
    TO admin_role, manager_role, member_role, user_role;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE generate_12digit_id
    TO admin_role, manager_role, member_role, user_role;


GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA public TO admin_role;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO manager_role, member_role, user_role;

GRANT INSERT, UPDATE ON account, album, forum, member, member_group,
    member_position, member_profile, merch, post_category, profile,
    shopping_cart, song TO manager_role;
GRANT UPDATE(order_status) ON shopping_order TO manager_role;

GRANT DELETE ON account, album, member, member_position,
    member_profile, merch, post, post_category,
    profile, shopping_cart, shopping_order, song TO manager_role;

GRANT INSERT, UPDATE, DELETE ON account, post_category, profile,
    shopping_cart, shopping_order TO member_role, user_role;

GRANT UPDATE(post_text, post_image_source, category_id) ON post TO user_role;

ALTER TABLE album ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum ENABLE ROW LEVEL SECURITY;
ALTER TABLE member ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_group ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_position ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE merch ENABLE ROW LEVEL SECURITY;
ALTER TABLE post ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_cart ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_order ENABLE ROW LEVEL SECURITY;
ALTER TABLE song ENABLE ROW LEVEL SECURITY;

CREATE POLICY admin_rights_album ON album
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_forum ON forum
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_member ON member
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_member_gr ON member_group
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_member_pos ON member_position
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_member_pr ON member_profile
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_merch ON merch
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_post ON post
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_profile ON profile
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_sh_cart ON shopping_cart
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_sh_ord ON shopping_order
TO admin_role
USING (TRUE);

CREATE POLICY admin_rights_song ON song
TO admin_role
USING (TRUE);


CREATE POLICY album_policy ON album
    FOR ALL
TO manager_role
USING (
    (SELECT group_manager FROM member_group
                          WHERE group_id =
                                album.group_owner_id) = CURRENT_USER
    );

CREATE POLICY forum_policy ON forum
    FOR ALL
TO manager_role
USING (
    (SELECT group_manager FROM member_group
                          WHERE member_group.group_id =
                                forum.group_id) = CURRENT_USER
    );

CREATE POLICY member_policy ON member
    FOR ALL
TO manager_role
USING (
    (SELECT group_manager FROM member_group
                          WHERE member_group.group_id =
                                member.group_id) = CURRENT_USER
    );

CREATE POLICY member_gr_policy ON member_group
    FOR ALL
TO manager_role
USING (
    (SELECT group_manager FROM member_group) = CURRENT_USER
    );

CREATE POLICY member_pos_policy ON member_position
    FOR ALL
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN member ON member_group.group_id = member.group_id
    JOIN member_position mp on member.member_id = mp.member_id) = CURRENT_USER
    );

CREATE POLICY member_pr_policy ON member_profile
    FOR ALL
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN member on member_group.group_id = member.group_id
    JOIN member_profile ON member.member_id =
                           member_profile.member_id) = CURRENT_USER
    );

CREATE POLICY song_policy ON song
    FOR ALL
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN album ON member_group.group_id = album.group_owner_id
    JOIN song ON album.album_id = song.album_id) = CURRENT_USER
    );

CREATE POLICY upd_merch_policy ON merch
    FOR UPDATE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN merch ON member_group.group_id = merch.group_id) = CURRENT_USER
    );

CREATE POLICY ins_merch_policy ON merch
    FOR INSERT
TO manager_role
WITH CHECK (
    (SELECT group_manager FROM member_group
    JOIN merch ON member_group.group_id = merch.group_id) = CURRENT_USER
    );

CREATE POLICY post_policy_member ON post
    FOR INSERT
TO member_role
WITH CHECK (
    (SELECT profile.account_login FROM profile
    JOIN member_profile ON profile.profile_id = member_profile.profile_id
    JOIN member ON member_profile.member_id = member.member_id
    JOIN member_group ON member.group_id = member_group.group_id
    JOIN forum ON member_group.group_id = forum.group_id) = CURRENT_USER
    );

CREATE POLICY post_policy_upd ON post
    FOR UPDATE
TO user_role
USING (TRUE);

CREATE POLICY post_policy_dlt ON post
    FOR DELETE
TO user_role
USING (TRUE);

CREATE POLICY profile_policy ON profile
    FOR ALL
TO user_role
USING (
    (SELECT account_login FROM profile) = CURRENT_USER
    );

CREATE POLICY sh_ord_manager ON shopping_order
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN merch ON member_group.group_id = merch.group_id
    JOIN shopping_order ON merch.merch_id =
                           shopping_order.merch_id) = CURRENT_USER
    );

CREATE POLICY sh_cart_policy ON shopping_cart
    FOR ALL
TO user_role
USING (
    (SELECT account_login FROM shopping_cart) = CURRENT_USER
    );

CREATE POLICY sh_ord_policy ON shopping_order
    FOR ALL
TO user_role
USING (
    (SELECT account_login FROM shopping_cart) = CURRENT_USER
    );