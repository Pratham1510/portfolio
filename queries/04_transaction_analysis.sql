-- =============================================================
-- Banking Analytics — Transaction Analysis
-- Techniques: time-series, rolling windows, LAG/LEAD, ROLLUP
-- =============================================================

-- ------------------------------------------------------------
-- 1. Monthly transaction volume and value (last 12 months)
-- ------------------------------------------------------------
SELECT
    DATE_TRUNC('month', txn_date)::DATE          AS month,
    txn_type,
    COUNT(*)                                     AS txn_count,
    ROUND(SUM(amount), 2)                        AS total_amount,
    ROUND(AVG(amount), 2)                        AS avg_amount,
    ROUND(MAX(amount), 2)                        AS max_amount
FROM transactions
WHERE txn_date >= NOW() - INTERVAL '12 months'
GROUP BY ROLLUP (DATE_TRUNC('month', txn_date)::DATE, txn_type)
ORDER BY month NULLS LAST, txn_type;


-- ------------------------------------------------------------
-- 2. 3-month rolling average spend per account
--    (WITHDRAWAL + PAYMENT only)
-- ------------------------------------------------------------
WITH monthly_spend AS (
    SELECT
        account_id,
        DATE_TRUNC('month', txn_date)::DATE AS month,
        SUM(amount)                          AS monthly_amount
    FROM transactions
    WHERE txn_type IN ('WITHDRAWAL', 'PAYMENT')
    GROUP BY account_id, DATE_TRUNC('month', txn_date)::DATE
)
SELECT
    account_id,
    month,
    monthly_amount,
    ROUND(
        AVG(monthly_amount) OVER (
            PARTITION BY account_id
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_3m_avg,
    LAG(monthly_amount) OVER (PARTITION BY account_id ORDER BY month)  AS prev_month,
    ROUND(
        100.0 * (monthly_amount - LAG(monthly_amount) OVER (
                    PARTITION BY account_id ORDER BY month))
             / NULLIF(LAG(monthly_amount) OVER (
                    PARTITION BY account_id ORDER BY month), 0),
    1) AS mom_change_pct
FROM monthly_spend
ORDER BY account_id, month;


-- ------------------------------------------------------------
-- 3. Day-of-week spending patterns (all accounts combined)
-- ------------------------------------------------------------
SELECT
    TO_CHAR(txn_date, 'Day')              AS day_of_week,
    EXTRACT(DOW FROM txn_date)::INT        AS dow_num,   -- 0=Sun
    COUNT(*)                              AS txn_count,
    ROUND(AVG(amount), 2)                 AS avg_amount,
    ROUND(SUM(amount), 2)                 AS total_amount
FROM transactions
WHERE txn_type IN ('WITHDRAWAL', 'PAYMENT', 'PURCHASE')
GROUP BY TO_CHAR(txn_date, 'Day'), EXTRACT(DOW FROM txn_date)::INT
ORDER BY dow_num;


-- ------------------------------------------------------------
-- 4. Spending by category with share of wallet
-- ------------------------------------------------------------
WITH category_totals AS (
    SELECT
        COALESCE(category, 'UNCATEGORISED') AS category,
        COUNT(*)                            AS txn_count,
        ROUND(SUM(amount), 2)               AS total_spend
    FROM transactions
    WHERE txn_type IN ('WITHDRAWAL','PAYMENT')
    GROUP BY category
)
SELECT
    category,
    txn_count,
    total_spend,
    ROUND(100.0 * total_spend / SUM(total_spend) OVER (), 2) AS pct_of_total,
    RANK() OVER (ORDER BY total_spend DESC)                   AS spend_rank
FROM category_totals
ORDER BY total_spend DESC;


-- ------------------------------------------------------------
-- 5. Accounts whose balance declined month-over-month
--    for 3+ consecutive months  (using LAG chain)
-- ------------------------------------------------------------
WITH monthly_balances AS (
    SELECT
        account_id,
        DATE_TRUNC('month', txn_date)::DATE AS month,
        LAST_VALUE(balance_after) OVER (
            PARTITION BY account_id, DATE_TRUNC('month', txn_date)::DATE
            ORDER BY txn_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS eom_balance
    FROM transactions
),
distinct_months AS (
    SELECT DISTINCT account_id, month, eom_balance FROM monthly_balances
),
with_lags AS (
    SELECT
        account_id,
        month,
        eom_balance,
        LAG(eom_balance, 1) OVER (PARTITION BY account_id ORDER BY month) AS bal_1m_ago,
        LAG(eom_balance, 2) OVER (PARTITION BY account_id ORDER BY month) AS bal_2m_ago,
        LAG(eom_balance, 3) OVER (PARTITION BY account_id ORDER BY month) AS bal_3m_ago
    FROM distinct_months
)
SELECT
    account_id,
    month,
    eom_balance,
    bal_1m_ago,
    bal_2m_ago,
    bal_3m_ago
FROM with_lags
WHERE
    eom_balance < bal_1m_ago
    AND bal_1m_ago < bal_2m_ago
    AND bal_2m_ago < bal_3m_ago
ORDER BY account_id, month;


-- ------------------------------------------------------------
-- 6. First and most recent transaction per account
--    (pattern: FIRST_VALUE / LAST_VALUE)
-- ------------------------------------------------------------
SELECT DISTINCT
    account_id,
    FIRST_VALUE(txn_date)    OVER w AS first_txn_date,
    FIRST_VALUE(txn_type)    OVER w AS first_txn_type,
    FIRST_VALUE(amount)      OVER w AS first_txn_amount,
    LAST_VALUE(txn_date)     OVER w AS latest_txn_date,
    LAST_VALUE(txn_type)     OVER w AS latest_txn_type,
    LAST_VALUE(amount)       OVER w AS latest_txn_amount,
    COUNT(*) OVER (PARTITION BY account_id) AS lifetime_txns
FROM transactions
WINDOW w AS (
    PARTITION BY account_id
    ORDER BY txn_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
ORDER BY account_id;
