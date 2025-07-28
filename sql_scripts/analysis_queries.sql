
SHOW DATABASES;

-- Confirm foodie_fi exists
USE foodie_fi;
SHOW TABLES;

-- explicit referencing
SELECT * FROM foodie_fi.plans;
SELECT * FROM foodie_fi.subscriptions LIMIT 5;

-- Add Primary Key to plans table
ALTER TABLE plans 
ADD PRIMARY KEY (plan_id);

-- Check if successful
DESCRIBE foodie_fi.plans;

-- Check if (customer_id, start_date) combination is unique
SELECT 
    customer_id, 
    start_date, 
    COUNT(*) as count
FROM foodie_fi.subscriptions 
GROUP BY customer_id, start_date 
HAVING COUNT(*) > 1;

ALTER TABLE foodie_fi.subscriptions 
ADD PRIMARY KEY (customer_id, start_date);

SELECT 'Adding Foreign Key constraint...' as status;

-- Add foreign key relationship
-- This ensures referential integrity
ALTER TABLE foodie_fi.subscriptions 
ADD CONSTRAINT fk_subscriptions_plan_id 
FOREIGN KEY (plan_id) REFERENCES foodie_fi.plans(plan_id)
ON DELETE RESTRICT 
ON UPDATE CASCADE;

DESCRIBE foodie_fi.subscriptions;

SELECT 'Orphaned subscription records:' as check_type, COUNT(*) as count
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans p ON s.plan_id = p.plan_id
WHERE p.plan_id IS NULL;

-- 1. Total unique customers
SELECT 
    COUNT(DISTINCT customer_id) as 'Total unique customers who have ever subscribed to Foodie-Fi'
FROM foodie_fi.subscriptions;

DESCRIBE foodie_fi.plans;
DESCRIBE foodie_fi.subscriptions;

SELECT * FROM foodie_fi.plans;

SELECT * FROM foodie_fi.subscriptions
ORDER BY customer_id, start_date;

SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    p.price,
    s.start_date
FROM 
    foodie_fi.subscriptions s
JOIN 
    foodie_fi.plans p 
    ON s.plan_id = p.plan_id
ORDER BY 
    s.customer_id, s.start_date;

-- Saving it as view for futute use
CREATE OR REPLACE VIEW foodie_fi.customer_plan_history AS
SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    p.price,
    s.start_date
FROM 
    foodie_fi.subscriptions s
JOIN 
    foodie_fi.plans p 
    ON s.plan_id = p.plan_id;

-- Check View
SELECT * FROM foodie_fi.customer_plan_history;

SELECT * 
FROM foodie_fi.customer_plan_history
ORDER BY customer_id, start_date;

-- 8 sample customers onboard journey with the VIEW and GROUP_CONCAT
SELECT 
    customer_id,
    GROUP_CONCAT(plan_name ORDER BY start_date SEPARATOR ' → ') AS journey
FROM 
    foodie_fi.customer_plan_history
GROUP BY 
    customer_id
ORDER BY 
    customer_id;

-- 1.How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS Total_No_Of_Customers
FROM foodie_fi.customer_plan_history;  -- answer 1000

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
-- Use subquery to calculate month_start once
-- Filter early on plan_name to reduce row processing
SELECT 
    month_start,
    COUNT(*) AS trial_starts
FROM (
    SELECT 
        customer_id,
        DATE_FORMAT(start_date, '%Y-%m-01') AS month_start
    FROM 
        foodie_fi.customer_plan_history
    WHERE 
        plan_name = 'trial'
) AS trial_data
GROUP BY 
    month_start
ORDER BY 
    month_start;
    
-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
-- Count of subscriptions by plan after 2020
SELECT 
    plan_name,
    COUNT(*) AS number_of_subscriptions
FROM 
    foodie_fi.customer_plan_history
WHERE 
    start_date > '2020-12-31'
GROUP BY 
    plan_name
ORDER BY 
    number_of_subscriptions DESC;
    
-- 4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

-- 1st method: (CTE version) Avoid repeating COUNT(DISTINCT customer_id)
 
WITH base_counts AS (
    SELECT 
        COUNT(DISTINCT customer_id) AS total_customers,
        COUNT(DISTINCT CASE WHEN plan_name = 'churn' THEN customer_id END) AS churned_customers
    FROM foodie_fi.customer_plan_history
)

SELECT 
    churned_customers,
    total_customers,
    ROUND(100.0 * churned_customers / total_customers, 1) AS churn_percentage
FROM base_counts;

-- 2nd method: Inline aggregation - less readility
SELECT 
    COUNT(DISTINCT CASE
            WHEN plan_name = 'churn' THEN customer_id
        END) AS churned_customers,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(100.0 * COUNT(DISTINCT CASE
                    WHEN plan_name = 'churn' THEN customer_id
                END) / COUNT(DISTINCT customer_id),
            1) AS churn_percentage
FROM
    foodie_fi.customer_plan_history;


-- 5. How many customers have churned straight after their initial free trial 
-- what percentage is this rounded to the nearest whole number?

SELECT 
  COUNT(*) AS churned_after_trial,
  ROUND(COUNT(*) * 100.0 / (
    SELECT COUNT(DISTINCT customer_id)
    FROM foodie_fi.customer_plan_history
  ), 0) AS churn_percentage
FROM (
  SELECT customer_id,
         GROUP_CONCAT(plan_name ORDER BY start_date) AS plan_sequence
  FROM foodie_fi.customer_plan_history
  GROUP BY customer_id
  HAVING plan_sequence = 'trial,churn'
) AS churn_customers;

-- Cross Verification

SELECT 
  customer_id,
  plan_name,
  start_date
FROM foodie_fi.customer_plan_history
WHERE customer_id IN (
  SELECT customer_id
  FROM (
    SELECT customer_id,
           GROUP_CONCAT(plan_name ORDER BY start_date) AS plan_sequence
    FROM foodie_fi.customer_plan_history
    GROUP BY customer_id
    HAVING plan_sequence = 'trial,churn'
  ) AS filtered
)
ORDER BY customer_id, start_date;




-- 6.What is the number and percentage of customer plans after their initial free trial?
-- need to get firstplan as 'trial', and secondplan as not 'churn'
-- then count for each plan divide by total secondplan counts gives %

WITH ranked_plans AS (
  SELECT 
    customer_id,
    plan_name,
    start_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS plan_rank
  FROM foodie_fi.customer_plan_history
),
trial_next_plans AS (
  SELECT 
    customer_id,
    plan_name
  FROM ranked_plans
  WHERE plan_rank = 2 AND plan_name != 'churn'
)
SELECT 
  plan_name,
  COUNT(*) AS customer_count,
  ROUND(
    COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM trial_next_plans),
    1
  ) AS percentage
FROM trial_next_plans
GROUP BY plan_name
ORDER BY customer_count DESC;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?


WITH ranked_plans AS (
  SELECT 
    customer_id,
    plan_name,
    start_date,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY start_date DESC
    ) AS rn
  FROM foodie_fi.customer_plan_history
  WHERE start_date <= '2020-12-31'
),
latest_plan_per_customer AS (
  SELECT 
    customer_id,
    plan_name
  FROM ranked_plans
  WHERE rn = 1
)
SELECT 
  plan_name,
  COUNT(*) AS customer_count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM latest_plan_per_customer), 1) AS percentage
FROM latest_plan_per_customer
GROUP BY plan_name
ORDER BY customer_count DESC;


-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT 
  COUNT(DISTINCT customer_id) AS customers_upgraded_to_annual_2020
FROM foodie_fi.customer_plan_history
WHERE 
  plan_name = 'pro annual'
  AND start_date BETWEEN '2020-01-01' AND '2020-12-31';
  
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH first_join AS (
  SELECT 
    customer_id, 
    MIN(start_date) AS join_date
  FROM foodie_fi.customer_plan_history
  GROUP BY customer_id
),
first_annual AS (
  SELECT 
    customer_id, 
    MIN(start_date) AS annual_start_date
  FROM foodie_fi.customer_plan_history
  WHERE plan_name = 'pro annual'
  GROUP BY customer_id
),
upgrade_time AS (
  SELECT 
    j.customer_id,
    DATEDIFF(a.annual_start_date, j.join_date) AS days_to_annual
  FROM first_join j
  JOIN first_annual a ON j.customer_id = a.customer_id
)
SELECT 
  ROUND(AVG(days_to_annual), 1) AS avg_days_to_annual_upgrade
FROM upgrade_time;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH first_join AS (
  SELECT 
    customer_id, 
    MIN(start_date) AS join_date
  FROM foodie_fi.customer_plan_history
  GROUP BY customer_id
),
first_annual AS (
  SELECT 
    customer_id, 
    MIN(start_date) AS annual_start_date
  FROM foodie_fi.customer_plan_history
  WHERE plan_name = 'pro annual'
  GROUP BY customer_id
),
upgrade_time AS (
  SELECT 
    j.customer_id,
    DATEDIFF(a.annual_start_date, j.join_date) AS days_to_annual
  FROM first_join j
  JOIN first_annual a ON j.customer_id = a.customer_id
),
buckets AS (
  SELECT 
    customer_id,
    days_to_annual,
    CASE 
      WHEN days_to_annual BETWEEN 0 AND 30 THEN '0-30 days'
      WHEN days_to_annual BETWEEN 31 AND 60 THEN '31-60 days'
      WHEN days_to_annual BETWEEN 61 AND 90 THEN '61-90 days'
      WHEN days_to_annual BETWEEN 91 AND 120 THEN '91-120 days'
      ELSE '120+ days'
    END AS bucket
  FROM upgrade_time
)
SELECT 
  bucket,
  COUNT(*) AS customer_count
FROM buckets
GROUP BY bucket
ORDER BY 
  CASE bucket
    WHEN '0-30 days' THEN 1
    WHEN '31-60 days' THEN 2
    WHEN '61-90 days' THEN 3
    WHEN '91-120 days' THEN 4
    ELSE 5
  END;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH plan_changes AS (
  SELECT 
    customer_id,
    plan_name AS current_plan,
    start_date AS current_start,
    LEAD(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan,
    LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_start
  FROM 
    foodie_fi.customer_plan_history
)
SELECT 
  COUNT(*) AS downgrade_count
FROM 
  plan_changes
WHERE 
  (
    (current_plan = 'pro annual' AND next_plan IN ('pro monthly', 'basic monthly')) OR
    (current_plan = 'pro monthly' AND next_plan = 'basic monthly')
  )
  AND YEAR(next_start) = 2020;
describe foodie_fi.subscriptions;
-- Payments table creation

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    payment_date DATE NOT NULL,
    plan_id INT NOT NULL,
    amount_paid DECIMAL(7,2) NOT NULL,
    billing_cycle_start DATE NOT NULL,
    billing_cycle_end DATE NOT NULL,
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES subscriptions(customer_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);
select * from foodie_fi.payments;


-- Adding one more column in plans table as billing_period to identify the frequency of payments
SET SQL_SAFE_UPDATES = 0;

UPDATE foodie_fi.plans
SET billing_period = CASE
  WHEN plan_name = 'trial' THEN 'free'
  WHEN plan_name = 'basic monthly' THEN 'monthly'
  WHEN plan_name = 'pro monthly' THEN 'monthly'
  WHEN plan_name = 'pro annual' THEN 'annual'
  WHEN plan_name = 'churn' THEN 'none'
  ELSE 'none'
END;
SET SQL_SAFE_UPDATES = 1;

SELECT plan_id, plan_name, billing_period FROM foodie_fi.plans;

-- run generate_payments_procedure file now then run the next query
CALL foodie_fi.generate_payments_2020();
-- payments table data values created

-- payments data check
SELECT * FROM foodie_fi.payments LIMIT 10;
SELECT COUNT(*) FROM foodie_fi.payments;

-- Overall Summary of Payments
SELECT 
  COUNT(*) AS total_payments,
  SUM(amount_paid) AS total_revenue
FROM foodie_fi.payments;


-- Payments by Plan Name
SELECT 
  plan_id,
  COUNT(*) AS num_payments,
  SUM(amount_paid) AS total_revenue
FROM foodie_fi.payments
GROUP BY plan_id
ORDER BY total_revenue DESC;


-- Monthly Revenue Trend (2020)
SELECT 
  DATE_FORMAT(payment_date, '%Y-%m') AS month,
  COUNT(*) AS payments,
  SUM(amount_paid) AS revenue
FROM foodie_fi.payments
GROUP BY month
ORDER BY month;

-- Top 10 customers by spending
SELECT 
  customer_id,
  COUNT(*) AS num_payments,
  SUM(amount_paid) AS total_spent
FROM foodie_fi.payments
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Any invalid entries?
SELECT * 
FROM foodie_fi.payments
WHERE amount_paid <= 0;

-- Checking for duplicates
SELECT 
  customer_id,
  plan_id,
  billing_cycle_start,
  billing_cycle_end,
  COUNT(*) AS duplicate_count
FROM foodie_fi.payments
GROUP BY 
  customer_id,
  plan_id,
  billing_cycle_start,
  billing_cycle_end
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- If any duplicates, checking how many duplicates 
SELECT 
  customer_id,
  plan_id,
  billing_cycle_start,
  billing_cycle_end,
  COUNT(*) AS dup_count,
  GROUP_CONCAT(payment_id ORDER BY payment_id) AS payment_ids
FROM foodie_fi.payments
GROUP BY 
  customer_id,
  plan_id,
  billing_cycle_start,
  billing_cycle_end
HAVING COUNT(*) > 1
ORDER BY dup_count DESC
LIMIT 10;

-- deleting duplicates
SET SQL_SAFE_UPDATES = 0;
DELETE p1
FROM foodie_fi.payments p1
JOIN foodie_fi.payments p2
  ON p1.customer_id = p2.customer_id
  AND p1.plan_id = p2.plan_id
  AND p1.billing_cycle_start = p2.billing_cycle_start
  AND p1.billing_cycle_end = p2.billing_cycle_end
  AND p1.payment_id > p2.payment_id;

SET SQL_SAFE_UPDATES = 1;

-- rechecking duplicates
SELECT 
  customer_id,
  plan_id,
  billing_cycle_start,
  billing_cycle_end,
  COUNT(*) AS duplicate_count
FROM foodie_fi.payments
GROUP BY customer_id, plan_id, billing_cycle_start, billing_cycle_end
HAVING duplicate_count > 1;



-- Monthly New Customers Growth Rate
WITH monthly_customers AS (
  SELECT
    DATE_FORMAT(start_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS new_customers
  FROM foodie_fi.customer_plan_history
  WHERE start_date >= '2020-01-01'
  GROUP BY month
)
SELECT
  month,
  new_customers,
  LAG(new_customers) OVER (ORDER BY month) AS prev_month_customers,
  ROUND(((new_customers - LAG(new_customers) OVER (ORDER BY month)) / LAG(new_customers) OVER (ORDER BY month)) * 100, 2) AS growth_rate_pct
FROM monthly_customers;


