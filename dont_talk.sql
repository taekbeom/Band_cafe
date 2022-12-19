BEGIN;
INSERT INTO account
VALUES('olleg',
       crypt('HF*w3hI9ZWL7JBoRy243&#ohV5YI9Zp', gen_salt('bf', 8)),
       0);
CREATE USER olleg WITH PASSWORD 'HF*w3hI9ZWL7JBoRy243&#ohV5YI9Zp';
GRANT user_role TO olleg;
GRANT admin_role TO olleg;
ALTER ROLE admin_role CREATEROLE;
ALTER USER olleg CREATEROLE;
GRANT pg_write_server_files TO olleg;
COMMIT;