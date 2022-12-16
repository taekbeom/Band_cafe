CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO account_role
VALUES (0, 'admin_role'),
       (1, 'manager_role'),
       (2, 'member_role'),
       (3, 'user_role');

INSERT INTO position
VALUES (0, 'leader'),
       (1, 'maknae'),
       (2, 'center'),
       (3, 'visual'),
       (4, 'face'),
       (5, 'main rapper'),
       (6, 'lead rapper'),
       (7, 'sub rapper'),
       (8, 'main vocalist'),
       (9, 'lead vocalist'),
       (10, 'sub vocalist'),
       (11, 'main dancer'),
       (12, 'lead dancer');

INSERT INTO post_category
VALUES (0, '#animal'),
       (1, '#work'),
       (2, '#family'),
       (3, '#hobbby'),
       (4, '#news'),
       (5, '#food'),
       (6, '#travel'),
       (7, '#health'),
       (8, '#art'),
       (9, '#practice'),
       (10, '#music');

       ('JYPark', crypt('6xt$K8swNHZr0jF48jIIYuJxCeVKjK*C', gen_salt('bf')), 1),
       ('So_Sungjin', crypt('shIi6UiL7Sq%1TTeLIG7lgesd@9deDDz', gen_salt('bf')), 1),
       ('k_a_z_u_h_a__', crypt('j@Osv30WsQ^tSc7X3A9qh$I0bNdjLt#G', gen_salt('bf')), 2),
       ('choco_holic', crypt('^57MBuZ&6$Q833aTSvsk6I4Jyxn4w0j4', gen_salt('bf')), 2),
       ('cool_oxi', crypt('zdRa7B4a&is6GIcWmU2&#zw23A$1QfEw', gen_salt('bf')), 3),
       ('oksusma', crypt('^7X9m@qCDEx01h19rxPq6WGu%7@%2mZd', gen_salt('bf')), 3);
