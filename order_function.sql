CREATE OR REPLACE PROCEDURE add_order(set_account_login VARCHAR(32),
new_merch_id VARCHAR(12),
new_order_amount INTEGER,
new_order_address TEXT
)
LANGUAGE plpgsql
AS $$
    DECLARE digit_id VARCHAR(12);
        generate_digit_id TEXT;
BEGIN
    IF (SELECT COUNT(*) FROM merch
                        WHERE merch_id = new_merch_id) > 0
    AND
    (new_order_amount <= 10)
    AND
    (new_order_amount > 0)
    AND
    (new_order_amount <= (SELECT merch_amount FROM merch
                         WHERE merch_id = new_merch_id)) THEN
        generate_digit_id := (SELECT nextval('generate_order_id'))::TEXT;
        digit_id := lpad(generate_digit_id, 12, '0');
        INSERT INTO shopping_order(order_id, order_address,
                                   order_amount, shopping_cart_id, merch_id)
        VALUES (concat('sord', digit_id),
                new_order_address, new_order_amount,
                (SELECT shopping_cart_id FROM shopping_cart
                WHERE account_login = set_account_login),
                new_merch_id);
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE update_order(upd_order_id VARCHAR(16),
new_order_address TEXT DEFAULT NULL,
new_order_amount INTEGER DEFAULT NULL,
select_confirm BOOLEAN DEFAULT FALSE)
LANGUAGE plpgsql
AS $$
BEGIN
    IF new_order_address IS NOT NULL AND length(new_order_address) = 0 THEN
            new_order_address := NULL;
        END IF;
    IF new_order_amount IS NOT NULL AND new_order_amount = 0 THEN
            new_order_amount := NULL;
        END IF;
    IF NOT (SELECT confirm_payment FROM shopping_order
        WHERE order_id = upd_order_id) THEN
            UPDATE shopping_order
            SET order_address = COALESCE(new_order_address, order_address),
            order_amount = COALESCE(new_order_amount, order_amount)
            WHERE order_id = upd_order_id;
        IF (select_confirm) AND
        (SELECT user_money FROM shopping_cart
         JOIN shopping_order ON shopping_cart.shopping_cart_id =
                                     shopping_order.shopping_cart_id
        WHERE order_id = upd_order_id) >=
        (SELECT order_amount FROM shopping_order
        WHERE order_id = upd_order_id) *
        (SELECT merch_price FROM merch
        JOIN shopping_order ON merch.merch_id = shopping_order.merch_id
        WHERE order_id = upd_order_id)
        AND
        (SELECT order_amount FROM shopping_order
        WHERE order_id = upd_order_id) <=
        (SELECT merch_amount FROM merch
        JOIN shopping_order ON merch.merch_id = shopping_order.merch_id
        WHERE order_id = upd_order_id) AND
        (SELECT merch_status FROM merch
        JOIN shopping_order ON merch.merch_id = shopping_order.merch_id
        WHERE order_id = upd_order_id)
        THEN
            UPDATE merch
            SET merch_amount = (merch_amount - (SELECT order_amount
                                                FROM shopping_order
                                                WHERE order_id = upd_order_id))
            WHERE merch_id = (SELECT merch_id FROM shopping_order
                             WHERE order_id = upd_order_id);
            UPDATE shopping_order
            SET confirm_payment = TRUE,
            order_add_date = CURRENT_DATE
            WHERE order_id = upd_order_id;
            UPDATE shopping_cart
            SET user_money = (user_money -
            (SELECT merch_price FROM merch
            JOIN shopping_order ON merch.merch_id = shopping_order.merch_id
            WHERE order_id = upd_order_id) *
            (SELECT order_amount FROM shopping_order
            WHERE order_id = upd_order_id))
            WHERE shopping_cart_id = (SELECT shopping_cart.shopping_cart_id
                                     FROM shopping_cart
                                     JOIN shopping_order
                                     ON shopping_cart.shopping_cart_id =
                                     shopping_order.shopping_cart_id
                                     WHERE order_id = upd_order_id);
            COMMIT;
        END IF;
    END IF;
END;$$;

CREATE OR REPLACE PROCEDURE delete_order(dlt_order_id VARCHAR(16))
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM shopping_order WHERE order_id = dlt_order_id;
END;$$;

CREATE OR REPLACE PROCEDURE change_order_status(upd_order_id VARCHAR(16),
upd_manager_login VARCHAR(32))
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT group_manager FROM member_group
    JOIN merch ON member_group.group_id = merch.group_id
    JOIN shopping_order ON merch.merch_id = shopping_order.merch_id
    WHERE order_id = upd_order_id) = upd_manager_login
    AND (SELECT order_status FROM shopping_order
    WHERE order_id = upd_order_id) < 2
    AND
    (SELECT confirm_payment FROM shopping_order
    WHERE order_id = upd_order_id)
    THEN
        UPDATE shopping_order
        SET order_status = (order_status + 1)
        WHERE order_id = upd_order_id;
    END IF;
END;$$;
