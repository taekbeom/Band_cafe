CREATE OR REPLACE PROCEDURE add_money(owner_account VARCHAR(32),
add_money_amount NUMERIC(12, 2))
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT COUNT(*) FROM account
                        WHERE account_login = owner_account) THEN
        UPDATE shopping_cart
        SET user_money = (user_money + round(add_money_amount, 2))
        WHERE account_login = owner_account;
    END IF;
END;$$;
