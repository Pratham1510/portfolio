-- =============================================================
-- Banking Analytics — Customer Insights
-- Techniques: CTEs, window functions, CASE, date arithmetic
-- =============================================================

-- ------------------------------------------------------------
-- 1. Customer Overview: age, tenure, total balance across accounts
-- ------------------------------------------------------------
WITH customer_balances AS (
    SELECT
        a.customer_id,
        COUNT(DISTINCT a.account_id)             AS total_accounts,
        SUM(CASE WHEN a.balance > 0 THEN a.balance ELSE 0 END) AS total_deposits,
        SUM(CASE WHEN a.balance < 0 THEN ABS(a.balance) ELSE 0 END) AS total_debt,
        SUM(a.balance)                           AS net_balance
    FROM accounts a
    WHERE a.status = 'ACTIVE'
    GROUP BY a.customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name          AS full_name,
    c.city || ', ' || c.state                   AS location,
    DATE_PART('year', AGE(c.date_of_birth))::INT AS age,
    DATE_PART('year', AGE(c.joined_date))::INT   AS tenure_years,
    cb.total_accounts,
    cb.total_deposits,
    cb.total_debt,
    cb.net_balance,
    RANK() OVER (ORDER BY cb.net_balance DESC)   AS balance_rank
FROM customers c
JOIN customer_balances cb USING (customer_id)
ORDER BY cb.net_balance DESC;


-- ------------------------------------------------------------
-- 2. Customer segmentation by age band and net worth tier
-- ------------------------------------------------------------
WITH customer_net AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS full_name,
        DATE_PART('year', AGE(c.date_of_birth))::INT AS age,
        COALESCE(SUM(a.balance), 0) AS net_balance
    FROM customers c
    LEFT JOIN accounts a ON a.customer_id = c.customer_id AND a.status = 'ACTIVE'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.date_of_birth
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN age < 30              THEN 'Gen Z (< 30)'
            WHEN age BETWEEN 30 AND 44 THEN 'Millennial (30–44)'
            WHEN age BETWEEN 45 AND 59 THEN 'Gen X (45–59)'
            ELSE                            'Boomer (60+)'
        END AS age_segment,
        CASE
            WHEN net_balance >= 100000 THEN 'High Net Worth'
            WHEN net_balance >= 25000  THEN 'Affluent'
            WHEN net_balance >= 5000   THEN 'Mass Market'
            ELSE                            'Starter'
        END AS wealth_tier
    FROM customer_net
)
SELECT
    age_segment,
    wealth_tier,
    COUNT(*)                             AS customer_count,
    ROUND(AVG(net_balance), 2)           AS avg_balance,
    ROUND(MIN(net_balance), 2)           AS min_balance,
    ROUND(MAX(net_balance), 2)           AS max_balance
FROM segmented
GROUP BY age_segment, wealth_tier
ORDER BY age_segment, avg_balance DESC;


-- ------------------------------------------------------------
-- 3. Top 10 customers by total deposits (with running total)
-- ------------------------------------------------------------
WITH deposits AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS full_name,
        COALESCE(SUM(CASE WHEN a.balance > 0 THEN a.balance ELSE 0 END), 0) AS total_deposits
    FROM customers c
    LEFT JOIN accounts a ON a.customer_id = c.customer_id AND a.status = 'ACTIVE'
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT
    RANK() OVER (ORDER BY total_deposits DESC) AS rank,
    full_name,
    total_deposits,
    SUM(total_deposits) OVER (ORDER BY total_deposits DESC
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    ROUND(100.0 * total_deposits /
          NULLIF(SUM(total_deposits) OVER (), 0), 2)                             AS pct_of_all_deposits
FROM deposits
ORDER BY rank
LIMIT 10;


-- ------------------------------------------------------------
-- 4. Customer churn risk: inactive accounts with no transactions
--    in the past 90 days, low balance
-- ------------------------------------------------------------
WITH last_activity AS (
    SELECT
        a.account_id,
        a.customer_id,
        a.balance,
        a.status,
        MAX(t.txn_date) AS last_txn_date
    FROM accounts a
    LEFT JOIN transactions t ON t.account_id = a.account_id
    WHERE a.status = 'ACTIVE'
    GROUP BY a.account_id, a.customer_id, a.balance, a.status
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    c.email,
    la.account_id,
    la.balance,
    la.last_txn_date,
    NOW()::DATE - la.last_txn_date::DATE AS days_since_activity,
    CASE
        WHEN la.last_txn_date IS NULL THEN 'Never transacted'
        WHEN NOW() - la.last_txn_date > INTERVAL '180 days' THEN 'HIGH RISK'
        WHEN NOW() - la.last_txn_date > INTERVAL '90 days'  THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS churn_risk
FROM last_activity la
JOIN customers c ON c.customer_id = la.customer_id
WHERE la.balance < 1000
   OR la.last_txn_date < NOW() - INTERVAL '90 days'
   OR la.last_txn_date IS NULL
ORDER BY days_since_activity DESC NULLS FIRST;


-- ------------------------------------------------------------
-- 5. Product cross-sell opportunities:
--    Customers with checking but no savings account
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    c.email,
    COUNT(a.account_id)                 AS total_accounts,
    STRING_AGG(p.product_type, ', ' ORDER BY p.product_type) AS held_products
FROM customers c
JOIN accounts a  ON a.customer_id = c.customer_id AND a.status = 'ACTIVE'
JOIN products p  ON p.product_id  = a.product_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
HAVING
    BOOL_OR(p.product_type = 'CHECKING')
    AND NOT BOOL_OR(p.product_type IN ('SAVINGS'))
ORDER BY total_accounts DESC;
