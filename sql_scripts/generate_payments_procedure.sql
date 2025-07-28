USE foodie_fi;


DROP PROCEDURE IF EXISTS generate_payments_2020;

-- Recreate the procedure using plan_id
DELIMITER //
CREATE PROCEDURE generate_payments_2020()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_customer_id INT;
    DECLARE v_start_date DATE;
    DECLARE v_plan_id INT;
    DECLARE v_next_date DATE;

    DECLARE cur CURSOR FOR
        SELECT customer_id, start_date, plan_id FROM subscriptions;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_customer_id, v_start_date, v_plan_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF v_plan_id = 0 THEN
            -- Free trial, no payment
            ITERATE read_loop;

        ELSEIF v_plan_id = 1 THEN
            -- Basic Monthly: $9.90/month
            SET v_next_date = v_start_date;
            WHILE v_next_date < '2021-01-01' DO
                INSERT INTO payments (customer_id, payment_date, plan_id, amount_paid, billing_cycle_start, billing_cycle_end)
                VALUES (v_customer_id, v_next_date, v_plan_id, 9.90,
                        v_next_date,
                        LAST_DAY(v_next_date));
                SET v_next_date = DATE_ADD(v_next_date, INTERVAL 1 MONTH);
            END WHILE;

        ELSEIF v_plan_id = 2 THEN
            -- Pro Monthly: $19.90/month
            SET v_next_date = v_start_date;
            WHILE v_next_date < '2021-01-01' DO
                INSERT INTO payments (customer_id, payment_date, plan_id, amount_paid, billing_cycle_start, billing_cycle_end)
                VALUES (v_customer_id, v_next_date, v_plan_id, 19.90,
                        v_next_date,
                        LAST_DAY(v_next_date));
                SET v_next_date = DATE_ADD(v_next_date, INTERVAL 1 MONTH);
            END WHILE;

        ELSEIF v_plan_id = 3 THEN
            -- Pro Annual: $199/year
            INSERT INTO payments (customer_id, payment_date, plan_id, amount_paid, billing_cycle_start, billing_cycle_end)
            VALUES (v_customer_id, v_start_date, v_plan_id, 199.00,
                    v_start_date,
                    DATE_ADD(v_start_date, INTERVAL 1 YEAR) - INTERVAL 1 DAY);
        END IF;
    END LOOP;

    CLOSE cur;
END //
DELIMITER ;


