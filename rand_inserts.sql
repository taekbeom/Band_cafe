CALL delete_user('olleg');
CALL delete_user('angela_soup');
CALL delete_user('kirill_why');
CALL delete_user('sanyacomeback');
CALL delete_user('k_a_z_u_h_a__');
CALL delete_user('_chaechae_1');
CALL delete_user('choco_holic');
CALL delete_user('ShinRyuJin');
CALL delete_user('OhBaekwon');
CALL delete_user('Kyujin');
CALL delete_user('Winteo');
CALL delete_user('riri');
CALL delete_user('cool_oxi');
CALL delete_user('oksusma');
DROP USER olleg;
DROP USER angela_soup;
DROP USER kirill_why;
DROP USER sanyacomeback;
DROP USER k_a_z_u_h_a__;
DROP USER _chaechae_1;
DROP USER choco_holic;
DROP USER "ShinRyuJin";
DROP USER "OhBaekwon";
DROP USER "Kyujin";
DROP USER "Winteo";
DROP USER riri;
DROP USER cool_oxi;
DROP USER oksusma;

CALL add_user('angela_soup', '6xt$K8swNHZr0jF48jIIYuJxCeVKjK*C');
CALL add_user('kirill_why', 'HAlM7yUvj6wc#$HCubhfD&3B0e9449KR*C');
CALL add_user('sanyacomeback', 'shIi6UiL7Sq%1TTeLIG7lgesd@9deDDz');
CALL add_user('k_a_z_u_h_a__', 'j@Osv30WsQ^tSc7X3A9qh$I0bNdjLt#G');
CALL add_user('_chaechae_1', 'YHw^7oh9^&878S9kVrEP^ZliXUzwmJWX');
CALL add_user('choco_holic', '^57MBuZ&6$Q833aTSvsk6I4Jyxn4w0j4');
CALL add_user('ShinRyuJin', 'bw1s^gu&TGJh7kx2cZAQW18eJODjOChP');
CALL add_user('OhBaekwon', 'F3rM7KHUmLQ%r10L91yefK6nu40rhLIf');
CALL add_user('Kyujin', 'LMoWIku@I*k31r#87efH$Q%Zna9oNG^3');
CALL add_user('Winteo', 'YuCjhB#PZkXh4ZYlZ7N89Gl91BE3zxVQ');
CALL add_user('riri', '%Dl^2gs28qKjdmp29zM0cX5!%7etcdai');

CALL add_user('cool_oxi', 'zdRa7B4a&is6GIcWmU2&#zw23A$1QfEw');
CALL add_user('oksusma', '^7X9m@qCDEx01h19rxPq6WGu%7@%2mZd');

CALL update_user('angela_soup', new_role_id := 1);
CALL update_user('kirill_why', new_role_id := 1);
CALL update_user('sanyacomeback', new_role_id := 1);

CALL add_label('SM Entertainment', 'И Суман',
    'Korea', 'Seoul', 'sm_address',
    '1995-02-14', 'description1.txt');
CALL add_label('JYP Entertainment', 'Пак Чинён',
    'Korea', 'Seoul', 'Кандонгу',
    '1997-04-25', 'description2.txt');
CALL add_label('Source Music', 'Со Сонджин',
    'Korea', 'Seoul', 'source_address',
    '2009-11-17', 'description3.txt');

CALL add_group('aespa', 'Korea',
    '2020-11-17', 'MY',
    'desc1.txt', 'angela_soup');

CALL add_group('ITZY', 'Korea',
    '2019-02-12', 'MIDZY',
    'desc2.txt', 'angela_soup');

CALL add_group('NMIXX', 'Korea',
    '2020-11-17', 'NSWER',
    'desc3.txt', 'kirill_why');

CALL add_group('LE SSERAFIM', 'Korea',
    '2022-05-02', 'FEARNOT',
    'desc4.txt', 'sanyacomeback');

CALL add_album('gr00000004', 'IT''Z ME',
    '2020-03-09');

CALL add_album('gr00000003', 'CHESHIRE',
    '2022-11-30','album_cover_path');

CALL add_album('gr00000001', 'Black Mamba/Single',
    '2020-11-17', 'album_cover_path2');

CALL add_song('albm00000002', 'WANNABE',
    191, 'song_mv1');

CALL add_song('albm00000001', '24HRS',
    128);

CALL add_song('albm00000002', 'Cheshire',
    183, 'song_mv2');

CALL add_song('albm00000002', 'Snowy',
    174);

CALL add_song('albm00000002', 'Freaky',
    176);

CALL add_song('albm00000003', 'Black Mamba',
    174, 'song_mv3');

CALl add_member('k_a_z_u_h_a__','lb0003KO','gr00000004',
    'Накамура Кадзуха', 'Кадзуха',
    '2003-08-09', 'Japan',
    'Kochi', 'descr1.txt', 170);

CALl add_member('_chaechae_1', 'lb0003KO','gr00000004',
    'Ким Чэвон', 'Ким Чэвон',
    '2000-08-01', 'Korea',
    'Seoul', 'descr2.txt', 163);

CALl add_member('choco_holic', 'lb0002KO','gr00000002',
    'И Чэрён', 'Чэрён',
    '2001-06-05', 'Korea',
    'Yongin', 'descr3.txt', 166);

CALl add_member('ShinRyuJin', 'lb0002KO','gr00000002',
    'Шин Рюджин', 'Рюджин',
    '2001-04-17', 'Korea',
    'Seoul', 'descr4.txt', 164);

CALl add_member('OhBaekwon', 'lb0002KO','gr00000003',
    'О Хэвон', 'Хэвон',
    '2003-02-25', 'Korea',
    'Incheon', 'descr5.txt', 163);

CALl add_member('Kyujin', 'lb0002KO','gr00000003',
    'Чжан Кюджин', 'Кюджин',
    '2006-05-26', 'Korean',
    'Gyeonggi-do', 'descr6.txt', 166);

CALl add_member('Winteo', 'lb0001KO','gr00000001',
    'Ким Минджон', 'Винтер',
    '2001-01-01', 'Korea',
    'Busan', 'descr7.txt');

CALl add_member('riri', 'lb0001KO', 'gr00000001',
    'Учинага Эри', 'Жизель',
    '2000-10-30', 'Korea',
    'Garosu-gil', 'descr8.txt', 163);

CALL add_post('fr00010001', 'Winteo',
    'I''m sick of AI', null, null,
    7);
CALL add_post('fr00010001', 'oksusma',
    ':peeposad:', '/pepega.png',
    'f6a0843ed85441f8bb02ce251d4ca150');
CALL add_post('fr00010001', 'choco_holic',
    '>:(', null,
    'f6a0843ed85441f8bb02ce251d4ca150');
CALL add_post('fr00010001', 'cool_oxi',
    '21st soon', null,
    '97d6e8e531f044158de4f7c90c12bcbe');

CALL add_post('fr00020001', 'Kyujin',
    'why networks on test why', null);
CALL add_post('fr00020001', 'OhBaekwon',
    'nice day skip school');

CALL add_post('fr00010002', 'choco_holic',
    'walked with my dog^^', null,
    null,  0);
CALL add_post('fr00010002', 'kirill_why',
    ':shcok2000: u hav dog?', '/guoba.png',
    '04272a2a41e8446abfb35a34a9382522');
CALL add_post('fr00010002', 'ShinRyuJin',
    'wdym:0', null,
    'af6305c1afec4d19b940662325ee2a2e');
CALL add_post('fr00010002', 'oksusma',
    'i''m buying cat', '/dpgge.jpg',
    '04272a2a41e8446abfb35a34a9382522');
CALL add_post('fr00010002', 'oksusma',
    'actually now i have work:(', null,
    '04272a2a41e8446abfb35a34a9382522');
CALL add_post('fr00010002', 'cool_oxi',
    'aaaaaaaa', null,
    'af6305c1afec4d19b940662325ee2a2e');
