-- =============================================================
-- Banking Analytics — Product Performance
-- Techniques: GROUPING SETS, pivot-style FILTER, CTEs
-- =============================================================

-- ------------------------------------------------------------
-- 1. Product uptake: how many customers hold each product?
-- ------------------------------------------------------------
SELECT
    p.product_type,
    p.product_name,
    COUNT(DISTINCT a.customer_id)          AS customers_holding,
    COUNT(a.account_id)                    AS total_accounts,
    ROUND(AVG(a.balance), 2)               AS avg_balance,
    ROUND(SUM(CASE WHEN a.balance > 0 THEN a.balance ELSE 0 END), 2) AS total_deposits_held,
    ROUND(100.0 * COUNT(DISTINCT a.customer_id)
          / NULLIF((SELECT COUNT(*) FROM customers WHERE is_active), 0), 1) AS penetration_pct
FROM products p
LEFT JOIN accounts a ON a.product_id = p.product_id AND a.status = 'ACTIVE'
GROUP BY p.product_id, p.product_type, p.product_name
ORDER BY customers_holding DESC;


-- ------------------------------------------------------------
-- 2. Checking vs Savings vs Credit: side-by-side comparison
--    (pivot-style using FILTER)
-- ------------------------------------------------------------
SELECT
    DATE_TRUNC('month', a.opened_date)::DATE AS cohort_month,
    COUNT(*) FILTER (WHERE p.product_type = 'CHECKING')     AS new_checking,
    COUNT(*) FILTER (WHERE p.product_type = 'SAVINGS')      AS new_savings,
    COUNT(*) FILTER (WHERE p.product_type = 'CREDIT_CARD')  AS new_credit_cards,
    COUNT(*) FILTER (WHERE p.product_type LIKE '%LOAN%')    AS new_loans,
    COUNT(*)                                                 AS total_new_accounts
FROM accounts a
JOIN products p ON p.product_id = a.product_id
GROUP BY DATE_TRUNC('month', a.opened_date)::DATE
ORDER BY cohort_month;


-- ------------------------------------------------------------
-- 3. Revenue estimate: monthly fee + interest income per product
-- ------------------------------------------------------------
WITH account_revenue AS (
    SELECT
        a.account_id,
        a.product_id,
        p.product_name,
        p.product_type,
        p.monthly_fee,
        -- Interest income on deposits (per month, simplified)
        CASE
            WHEN p.product_type IN ('SAVINGS','CHECKING') AND a.balance > 0
            THEN ROUND(a.balance * p.interest_rate / 100 / 12, 2)
            ELSE 0
        END AS deposit_interest_paid,   -- cost to bank
        -- Interest earned on credit balances owed
        CASE
            WHEN p.product_type = 'CREDIT_CARD' AND a.balance < 0
            THEN ROUND(ABS(a.balance) * p.interest_rate / 100 / 12, 2)
            ELSE 0
        END AS credit_interest_earned
    FROM accounts a
    JOIN products p ON p.product_id = a.product_id
    WHERE a.status = 'ACTIVE'
)
SELECT
    product_type,
    product_name,
    COUNT(*)                               AS active_accounts,
    ROUND(SUM(monthly_fee), 2)             AS total_monthly_fees,
    ROUND(SUM(credit_interest_earned), 2)  AS est_interest_income,
    ROUND(SUM(deposit_interest_paid), 2)   AS est_interest_expense,
    ROUND(SUM(monthly_fee)
          + SUM(credit_interest_earned)
          - SUM(deposit_interest_paid), 2) AS net_monthly_revenue
FROM account_revenue
GROUP BY product_type, product_name
ORDER BY net_monthly_revenue DESC;


-- ------------------------------------------------------------
-- 4. Loan portfolio health: breakdown by status and risk tier
-- ------------------------------------------------------------
WITH loan_risk AS (
    SELECT
        l.*,
        ROUND(l.total_paid / NULLIF(l.principal + (l.principal * l.interest_rate/100
              * l.term_months / 12), 0) * 100, 1) AS pct_repaid,
        CASE
            WHEN l.interest_rate < 7   THEN 'Prime'
            WHEN l.interest_rate < 12  THEN 'Near-Prime'
            ELSE                            'Sub-Prime'
        END AS risk_tier
    FROM loans l
)
SELECT
    status,
    risk_tier,
    COUNT(*)                          AS loan_count,
    ROUND(SUM(principal), 2)          AS total_principal,
    ROUND(AVG(interest_rate), 3)      AS avg_rate,
    ROUND(AVG(pct_repaid), 1)         AS avg_pct_repaid,
    ROUND(SUM(principal - total_paid), 2) AS outstanding_balance
FROM loan_risk
GROUP BY GROUPING SETS ((status, risk_tier), (status), ())
ORDER BY status NULLS LAST, risk_tier NULLS LAST;


-- ------------------------------------------------------------
-- 5. Multi-product households: customers with 3+ products
--    (cross-sell success metric)
-- ------------------------------------------------------------
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(DISTINCT p.product_type)     AS distinct_product_types,
    COUNT(DISTINCT a.account_id)       AS total_accounts,
    STRING_AGG(DISTINCT p.product_name, ' | ' ORDER BY p.product_name) AS products_held,
    ROUND(SUM(CASE WHEN a.balance > 0 THEN a.balance ELSE 0 END), 2) AS total_deposits,
    ROUND(SUM(CASE WHEN a.balance < 0 THEN ABS(a.balance) ELSE 0 END), 2) AS total_debt
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id AND a.status = 'ACTIVE'
JOIN products p ON p.product_id  = a.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT p.product_type) >= 3
ORDER BY distinct_product_types DESC, total_deposits DESC;
