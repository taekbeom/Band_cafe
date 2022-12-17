CALL add_user('olleg', 'HF*w3hI9ZWL7JBoRy243&#ohV5YI9Zp');
CALL update_user('olleg', new_role_id := 0);
GRANT admin_role TO olleg;
ALTER ROLE admin_role CREATEROLE;
ALTER USER olleg CREATEROLE;
GRANT pg_write_server_files TO olleg;
SELECT * FROM account;