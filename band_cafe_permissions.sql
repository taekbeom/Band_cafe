REVOKE ALL PRIVILEGES ON SCHEMA public FROM user_role;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM member_role;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM manager_role;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM admin_role;

DROP ROLE user_role;
DROP ROLE member_role;
DROP ROLE manager_role;
DROP ROLE admin_role;

CREATE ROLE user_role;
CREATE ROLE member_role;
CREATE ROLE manager_role;
CREATE ROLE admin_role;


GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public
    TO admin_role, manager_role, member_role, user_role;


GRANT INSERT, UPDATE, DELETE ON
    account, profile, shopping_order,shopping_cart,
    post TO manager_role, member_role, user_role;

GRANT UPDATE(merch_amount) ON merch TO member_role, user_role;

GRANT DELETE, UPDATE ON member TO member_role;

GRANT DELETE ON member_profile, member_position
    TO member_role;

GRANT INSERT, UPDATE, DELETE ON
    album, member, song
    TO manager_role;

GRANT INSERT, UPDATE ON
    forum, member_group, merch, group_label
    TO manager_role;

GRANT INSERT, DELETE ON
    member_profile, member_position
    TO manager_role;


ALTER TABLE album ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE forum DISABLE ROW LEVEL SECURITY;
ALTER TABLE member ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_group ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE member_group DISABLE ROW LEVEL SECURITY;
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


CREATE POLICY select_album ON album
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_forum ON forum
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_member ON member
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_member_gr ON member_group
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_member_pos ON member_position
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_member_pr ON member_profile
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_merch ON merch
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_post ON post
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_profile ON profile
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_song ON song
    FOR SELECT
TO manager_role, member_role, user_role
USING (TRUE);

CREATE POLICY select_sh_cart ON shopping_cart
    FOR SELECT
TO manager_role, member_role, user_role
USING (
    account_login = CURRENT_USER
    );

CREATE POLICY select_sh_ord ON shopping_order
    FOR SELECT
TO member_role, user_role
USING (
    (SELECT account_login FROM shopping_cart
    WHERE shopping_cart.shopping_cart_id
              = shopping_order.shopping_cart_id) = CURRENT_USER
    );

CREATE POLICY select_sh_ord_manager ON shopping_order
    FOR SELECT
TO manager_role
USING (
    (SELECT account_login FROM shopping_cart
    WHERE shopping_order.shopping_cart_id
                              = shopping_cart.shopping_cart_id) = CURRENT_USER
    OR
    (SELECT group_manager FROM member_group
    JOIN merch ON member_group.group_id = merch.group_id
    WHERE merch.merch_id
                               = shopping_order.merch_id) = CURRENT_USER
    );

CREATE POLICY forum_policy_upd ON forum
    FOR UPDATE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    WHERE member_group.group_id
                      = forum.group_id) = CURRENT_USER
    );

CREATE POLICY forum_policy_ins ON forum
    FOR INSERT
TO manager_role
WITH CHECK (
    EXISTS(SELECT 1 FROM member_group
        WHERE forum.group_id = member_group.group_id
        AND group_manager = CURRENT_USER)
    );

CREATE POLICY member_gr_policy_upd ON member_group
    FOR UPDATE
TO manager_role
USING ( group_manager = CURRENT_USER);

CREATE POLICY member_gr_policy_ins ON member_group
    FOR INSERT
TO manager_role
WITH CHECK (TRUE);

CREATE POLICY merch_policy_upd ON merch
    FOR UPDATE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    WHERE member_group.group_id = merch.group_id)
        = CURRENT_USER
    OR
    (SELECT account_login FROM shopping_cart
    JOIN shopping_order ON shopping_cart.shopping_cart_id
                               = shopping_order.shopping_cart_id
    WHERE merch.merch_id = shopping_order.merch_id) = CURRENT_USER
    );

CREATE POLICY merch_policy_ins ON merch
    FOR INSERT
TO manager_role
WITH CHECK (
    EXISTS(SELECT 1 FROM member_group
        WHERE merch.group_id = member_group.group_id
        AND group_manager = CURRENT_USER)
    );

CREATE POLICY member_pos_policy_dlt ON member_position
    FOR DELETE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN member ON member_group.group_id = member.group_id
    WHERE member.member_id = member_position.member_id)
        = CURRENT_USER
    );

CREATE POLICY member_pos_policy_ins ON member_position
    FOR INSERT
TO manager_role
WITH CHECK (
    EXISTS(SELECT 1 FROM member_group
          JOIN member ON member_group.group_id = member.group_id
        WHERE member.group_id = member_position.member_id
        AND group_manager = CURRENT_USER)
    );

CREATE POLICY member_pr_policy_dlt ON member_profile
    FOR DELETE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN member on member_group.group_id = member.group_id
    WHERE member.member_id =
                           member_profile.member_id) = CURRENT_USER
    );

CREATE POLICY member_pr_policy_ins ON member_profile
    FOR INSERT
TO manager_role
WITH CHECK (
    EXISTS(SELECT 1 FROM member_group
          JOIN member ON member_group.group_id = member.group_id
        WHERE member.member_id = member_profile.member_id
        AND group_manager = CURRENT_USER)
    );

CREATE POLICY album_policy_upd ON album
    FOR UPDATE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    WHERE member_group.group_id
                      = album.group_owner_id) = CURRENT_USER
    );

CREATE POLICY album_policy_dlt ON album
    FOR DELETE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    WHERE member_group.group_id
                      = album.group_owner_id) = CURRENT_USER
    );

CREATE POLICY album_policy_ins ON album
    FOR INSERT
TO manager_role
WITH CHECK (
    EXISTS(SELECT 1 FROM member_group
        WHERE album.group_owner_id = member_group.group_id
        AND group_manager = CURRENT_USER)
    );

CREATE POLICY member_policy_upd ON member
    FOR UPDATE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
     WHERE member_group.group_id = member.group_id)
        = CURRENT_USER
    );

CREATE POLICY member_policy_dlt ON member
    FOR DELETE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
     WHERE member_group.group_id = member.group_id)
        = CURRENT_USER
    );

CREATE POLICY member_policy_ins ON member
    FOR INSERT
TO manager_role
WITH CHECK (
    EXISTS(SELECT 1 FROM member_group
        WHERE member_group.group_id = member.group_id
        AND group_manager = CURRENT_USER)
    );

CREATE POLICY song_policy_upd ON song
    FOR UPDATE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN album ON member_group.group_id = album.group_owner_id
    WHERE album.album_id = song.album_id) = CURRENT_USER
    );

CREATE POLICY song_policy_dlt ON song
    FOR DELETE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN album ON member_group.group_id = album.group_owner_id
    WHERE album.album_id = song.album_id) = CURRENT_USER
    );

CREATE POLICY song_policy_ins ON song
    FOR INSERT
TO manager_role
WITH CHECK (
    EXISTS(SELECT 1 FROM member_group
          JOIN album ON member_group.group_id = album.group_owner_id
        WHERE song.album_id = album.album_id
        AND group_manager = CURRENT_USER)
    );

CREATE POLICY member_policy_member_dlt ON member
    FOR DELETE
TO member_role
USING (
    (SELECT account_login FROM profile
    JOIN member_profile ON profile.profile_id
                               = member_profile.profile_id
    WHERE member_profile.member_id = member.member_id)
        = CURRENT_USER
    );

CREATE POLICY member_policy_member_upd ON member
    FOR UPDATE
TO member_role
USING (
    (SELECT account_login FROM profile
    JOIN member_profile ON profile.profile_id
                               = member_profile.profile_id
    WHERE member_profile.member_id = member.member_id)
        = CURRENT_USER
    );

CREATE POLICY member_pr_policy_member ON member_profile
    FOR DELETE
TO member_role
USING (
    (SELECT account_login FROM profile
    WHERE profile.profile_id
                               = member_profile.profile_id)
    = CURRENT_USER
    );

CREATE POLICY member_pos_policy_member ON member_position
    FOR DELETE
TO member_role
USING (
    (SELECT account_login FROM profile
    JOIN member_profile ON profile.profile_id
                               = member_profile.profile_id
    JOIN member ON member_profile.member_id = member.member_id
    WHERE member.member_id
                                = member_position.member_id) = CURRENT_USER
    );

CREATE POLICY merch_policy_upd_all ON merch
    FOR UPDATE
TO member_role, user_role
USING (
    (SELECT account_login FROM shopping_cart
    JOIN shopping_order ON shopping_cart.shopping_cart_id
                               = shopping_order.shopping_cart_id
    WHERE merch.merch_id = shopping_order.merch_id) = CURRENT_USER
    );

CREATE POLICY account_policy_ins_all ON account
    FOR INSERT
TO manager_role, member_role, user_role
WITH CHECK (TRUE);

CREATE POLICY account_policy_upd_all ON account
    FOR UPDATE
TO member_role, user_role
USING (
    account_login = CURRENT_USER
    );

CREATE POLICY account_policy_dlt_all ON account
    FOR DELETE
TO manager_role, member_role, user_role
USING (
    account_login = CURRENT_USER
    );

CREATE POLICY profile_policy_ins_all ON profile
    FOR INSERT
TO manager_role, member_role, user_role
WITH CHECK (
    EXISTS(SELECT 1 FROM account
        WHERE profile.account_login = account.account_login
        AND account.account_login = CURRENT_USER)
    );

CREATE POLICY profile_policy_upd_all ON profile
    FOR UPDATE
TO member_role, user_role
USING (
    account_login = CURRENT_USER
    );

CREATE POLICY profile_policy_dlt_all ON profile
    FOR DELETE
TO manager_role, member_role, user_role
USING (
    account_login = CURRENT_USER
    );

CREATE POLICY sh_ord_policy_ins_all ON shopping_order
    FOR INSERT
TO manager_role, member_role, user_role
WITH CHECK (
    EXISTS(SELECT 1 FROM shopping_cart
        WHERE shopping_cart.shopping_cart_id = shopping_order.shopping_cart_id
        AND account_login = CURRENT_USER)
    );

CREATE POLICY sh_ord_policy_upd_all ON shopping_order
    FOR UPDATE
TO member_role, user_role
USING (
    (SELECT account_login FROM shopping_cart
    WHERE shopping_cart.shopping_cart_id
                               = shopping_order.shopping_cart_id) = CURRENT_USER
    );

CREATE POLICY sh_ord_policy_upd_manager ON shopping_order
    FOR UPDATE
TO manager_role
USING (
    (SELECT account_login FROM shopping_cart
    WHERE shopping_cart.shopping_cart_id
                               = shopping_order.shopping_cart_id) = CURRENT_USER
    OR
    (SELECT group_manager FROM member_group
    JOIN merch ON member_group.group_id = merch.group_id
    WHERE merch.merch_id = shopping_order.merch_id)
    = CURRENT_USER
    );

CREATE POLICY sh_ord_policy_dlt_all ON shopping_order
    FOR DELETE
TO manager_role, member_role, user_role
USING (
    (SELECT account_login FROM shopping_cart
    WHERE shopping_cart.shopping_cart_id
                               = shopping_order.shopping_cart_id) = CURRENT_USER
    );

CREATE POLICY sh_cart_policy_ins_all ON shopping_cart
    FOR INSERT
TO manager_role, member_role, user_role
WITH CHECK (
    EXISTS(SELECT 1 FROM account
        WHERE shopping_cart.account_login = account.account_login
        AND account.account_login = CURRENT_USER)
    );

CREATE POLICY sh_cart_policy_upd_all ON shopping_cart
    FOR UPDATE
TO manager_role, member_role, user_role
USING (
    account_login = CURRENT_USER
    );

CREATE POLICY sh_cart_policy_dlt_all ON shopping_cart
    FOR DELETE
TO manager_role, member_role, user_role
USING (
    account_login = CURRENT_USER
    );

CREATE POLICY post_policy_ins_all ON post
    FOR INSERT
TO manager_role, member_role, user_role
WITH CHECK (
    EXISTS(SELECT 1 FROM account
        WHERE account.account_login = post.author_login
        AND account_login = CURRENT_USER)
    );

CREATE POLICY post_policy_upd_all ON post
    FOR UPDATE
TO manager_role, member_role, user_role
USING (
    author_login = CURRENT_USER
    );

CREATE POLICY post_policy_dlt_all ON post
    FOR DELETE
TO user_role
USING (author_login = CURRENT_USER);

CREATE POLICY post_policy_dlt_thread ON post
    FOR DELETE
TO manager_role, member_role
USING (
    author_login = CURRENT_USER
    OR
    EXISTS(SELECT 1 FROM post
    WHERE reply_post_id = (
        SELECT post_id FROM post WHERE author_login = CURRENT_USER
        ))
    );

CREATE POLICY member_role_upd_manager ON account
    FOR UPDATE
TO manager_role
USING (
    (SELECT group_manager FROM member_group
    JOIN member ON member_group.group_id = member.group_id
    JOIN member_profile ON member.member_id = member_profile.member_id
    JOIN profile ON member_profile.profile_id = profile.profile_id
    WHERE profile.account_login = account.account_login)
    = CURRENT_USER
    OR
    account_login = CURRENT_USER
    );

CREATE POLICY member_profile_upd_manager ON profile
    FOR UPDATE
TO manager_role
    USING (
        (SELECT group_manager FROM member_group
    JOIN member ON member_group.group_id = member.group_id
    JOIN member_profile ON member.member_id = member_profile.member_id
    WHERE member_profile.profile_id = profile.profile_id)
    = CURRENT_USER
    OR
    account_login = CURRENT_USER);
