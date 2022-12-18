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
