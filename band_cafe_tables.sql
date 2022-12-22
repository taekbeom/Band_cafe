DROP TABLE IF EXISTS account CASCADE;
DROP TABLE IF EXISTS account_role CASCADE;
DROP TABLE IF EXISTS album CASCADE;
DROP TABLE IF EXISTS forum CASCADE;
DROP TABLE IF EXISTS group_label CASCADE;
DROP TABLE IF EXISTS member CASCADE;
DROP TABLE IF EXISTS member_group CASCADE;
DROP TABLE IF EXISTS member_position CASCADE;
DROP TABLE IF EXISTS merch CASCADE;
DROP TABLE IF EXISTS position CASCADE;
DROP TABLE IF EXISTS post CASCADE;
DROP TABLE IF EXISTS post_category CASCADE;
DROP TABLE IF EXISTS profile CASCADE;
DROP TABLE IF EXISTS shopping_cart CASCADE;
DROP TABLE IF EXISTS shopping_order CASCADE;
DROP TABLE IF EXISTS song CASCADE;
DROP TABLE IF EXISTS member_profile CASCADE;

CREATE TABLE IF NOT EXISTS account_role(
    role_id NUMERIC(1) PRIMARY KEY,
    role_name VARCHAR(32) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS account(
    account_login VARCHAR(32) PRIMARY KEY ,
    account_password TEXT NOT NULL,
    role_id NUMERIC(1) NOT NULL DEFAULT 3 REFERENCES account_role(role_id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS profile(
    profile_id VARCHAR(10) PRIMARY KEY,
    profile_avatar_source TEXT DEFAULT NULL,
    profile_date_of_birth DATE DEFAULT NULL,
    profile_description VARCHAR(64) DEFAULT NULL,
    account_login VARCHAR(32) NOT NULL UNIQUE REFERENCES account(account_login) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS shopping_cart(
    shopping_cart_id VARCHAR(10) PRIMARY KEY,
    user_money NUMERIC(12, 2) NOT NULL DEFAULT 0,
    account_login VARCHAR(32) NOT NULL UNIQUE REFERENCES account(account_login) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS member_group(
    group_id VARCHAR(10) PRIMARY KEY,
    group_name VARCHAR(128) NOT NULL UNIQUE,
    group_country VARCHAR(64) NOT NULL,
    group_debut_date DATE NOT NULL,
    group_disband_date DATE DEFAULT NULL,
    group_fandom_name VARCHAR(128) DEFAULT NULL UNIQUE,
    group_description_source TEXT NOT NULL,
    group_manager VARCHAR(32) NOT NULL REFERENCES account(account_login) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS merch(
    merch_id VARCHAR(12) PRIMARY KEY,
    merch_name TEXT NOT NULL,
    merch_price NUMERIC(12, 2) NOT NULL,
    merch_status BOOLEAN NOT NULL DEFAULT FALSE,
    merch_amount INTEGER NOT NULL,
    merch_description_source TEXT NOT NULL,
    group_id VARCHAR(10) NOT NULL REFERENCES member_group(group_id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS shopping_order(
    order_id VARCHAR(16) PRIMARY KEY,
    order_add_date DATE,
    order_status NUMERIC(1) NOT NULL DEFAULT 0,
    confirm_payment BOOLEAN NOT NULL DEFAULT FALSE,
    order_address TEXT NOT NULL,
    order_amount INTEGER NOT NULL DEFAULT 1,
    shopping_cart_id VARCHAR(10) NOT NULL REFERENCES shopping_cart(shopping_cart_id) ON UPDATE CASCADE,
    merch_id VARCHAR(12) NOT NULL REFERENCES merch(merch_id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS group_label(
    label_id VARCHAR(8) PRIMARY KEY,
    label_name VARCHAR(128) NOT NULL UNIQUE,
    label_director VARCHAR(128) NOT NULL,
    label_country VARCHAR(64) NOT NULL,
    label_city VARCHAR(64) NOT NULL,
    label_main_address TEXT NOT NULL,
    label_date DATE NOT NULL,
    label_description_source TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS member(
    member_id VARCHAR(12) PRIMARY KEY,
    member_name VARCHAR(128) NOT NULL,
    member_stage_name VARCHAR(128) NOT NULL,
    member_date_of_birth DATE NOT NULL,
    member_country VARCHAR(64) NOT NULL,
    member_city VARCHAR(64) NOT NULL,
    member_height NUMERIC(3) DEFAULT NULL,
    member_description_source TEXT NOT NULL,
    label_id VARCHAR(8) NOT NULL REFERENCES group_label(label_id) ON UPDATE CASCADE,
    group_id VARCHAR(10) NOT NULL REFERENCES member_group(group_id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS member_profile(
    member_id VARCHAR(12) NOT NULL REFERENCES member(member_id),
    profile_id VARCHAR(10) NOT NULL REFERENCES profile(profile_id),
    PRIMARY KEY (member_id, profile_id)
);

CREATE TABLE IF NOT EXISTS position(
    position_code NUMERIC(2) PRIMARY KEY,
    position_name VARCHAR(16) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS member_position(
    member_id VARCHAR(12) REFERENCES member(member_id) ON UPDATE CASCADE,
    position_code NUMERIC(2) REFERENCES position(position_code) ON UPDATE CASCADE,
    PRIMARY KEY (member_id, position_code)
);

CREATE TABLE IF NOT EXISTS album(
    album_id VARCHAR(12) PRIMARY KEY,
    album_name VARCHAR(128) NOT NULL,
    album_release_date DATE NOT NULL,
    album_cover TEXT DEFAULT NULL,
    group_owner_id VARCHAR(10) NOT NULL REFERENCES member_group(group_id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS song(
    song_id VARCHAR(16) PRIMARY KEY,
    song_name VARCHAR(128) NOT NULL,
    song_duration NUMERIC(4) NOT NULL,
    song_mv TEXT DEFAULT NULL,
    album_id VARCHAR(12) NOT NULL REFERENCES album(album_id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS forum(
    forum_id VARCHAR(10) PRIMARY KEY,
    forum_name TEXT NOT NULL UNIQUE,
    forum_description VARCHAR(64) NOT NULL,
    group_id VARCHAR(10) UNIQUE NOT NULL REFERENCES member_group(group_id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS post_category(
    category_id NUMERIC(2) PRIMARY KEY,
    category_name VARCHAR(32) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS post(
    post_id VARCHAR(32) PRIMARY KEY,
    post_text TEXT NOT NULL,
    post_date DATE NOT NULL,
    post_image_source TEXT,
    forum_id VARCHAR(10) NOT NULL REFERENCES forum(forum_id) ON UPDATE CASCADE,
    author_login VARCHAR(32) REFERENCES account(account_login) ON UPDATE CASCADE,
    reply_post_id VARCHAR(32) REFERENCES post(post_id) ON UPDATE CASCADE,
    category_id NUMERIC(2) REFERENCES post_category(category_id) ON UPDATE CASCADE
);
