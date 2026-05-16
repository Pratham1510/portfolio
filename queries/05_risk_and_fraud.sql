-- =============================================================
-- Banking Analytics — Risk & Fraud Detection
-- Techniques: correlated subqueries, self-joins, anomaly scoring
-- =============================================================

-- ------------------------------------------------------------
-- 1. Accounts with unresolved high/critical alerts
-- ------------------------------------------------------------
SELECT
    al.account_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(al.alert_id)                  AS open_alerts,
    STRING_AGG(al.alert_type, ' | ' ORDER BY al.severity DESC) AS alert_types,
    MAX(al.severity)                    AS max_severity,
    MIN(al.created_at)::DATE            AS oldest_alert_date
FROM alerts al
JOIN accounts a  ON a.account_id  = al.account_id
JOIN customers c ON c.customer_id = a.customer_id
WHERE al.resolved = FALSE
GROUP BY al.account_id, c.first_name, c.last_name
ORDER BY
    CASE MAX(al.severity)
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH'     THEN 2
        WHEN 'MEDIUM'   THEN 3
        ELSE                 4
    END;


-- ------------------------------------------------------------
-- 2. Transaction velocity: accounts with 3+ transactions
--    within any 1-hour window (rapid-fire pattern)
-- ------------------------------------------------------------
WITH txn_windows AS (
    SELECT
        t1.account_id,
        t1.transaction_id,
        t1.txn_date,
        t1.amount,
        COUNT(t2.transaction_id) AS txns_in_window
    FROM transactions t1
    JOIN transactions t2
        ON  t2.account_id = t1.account_id
        AND t2.txn_date   BETWEEN t1.txn_date AND t1.txn_date + INTERVAL '1 hour'
        AND t2.transaction_id <> t1.transaction_id
    GROUP BY t1.account_id, t1.transaction_id, t1.txn_date, t1.amount
)
SELECT
    account_id,
    txn_date,
    amount,
    txns_in_window + 1 AS cluster_size
FROM txn_windows
WHERE txns_in_window >= 2
ORDER BY txns_in_window DESC, account_id;


-- ------------------------------------------------------------
-- 3. Round-number large transactions (common structuring signal)
--    Amounts that are exact multiples of $1,000 and > $4,000
-- ------------------------------------------------------------
SELECT
    t.transaction_id,
    t.account_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    t.txn_date,
    t.txn_type,
    t.amount,
    t.description,
    t.is_flagged
FROM transactions t
JOIN accounts  a ON a.account_id  = t.account_id
JOIN customers c ON c.customer_id = a.customer_id
WHERE
    t.amount > 4000
    AND MOD(t.amount::NUMERIC, 1000) = 0
ORDER BY t.amount DESC, t.txn_date DESC;


-- ------------------------------------------------------------
-- 4. Composite fraud risk score per account
--    (weighted scoring model using CASE + aggregation)
-- ------------------------------------------------------------
WITH score_components AS (
    SELECT
        a.account_id,
        a.customer_id,
        -- Component 1: flagged transactions (0–40 pts)
        LEAST(40, COUNT(CASE WHEN t.is_flagged THEN 1 END) * 10)         AS flag_score,
        -- Component 2: open alerts (0–30 pts)
        LEAST(30, (SELECT COUNT(*) FROM alerts al
                   WHERE al.account_id = a.account_id AND NOT al.resolved) * 15) AS alert_score,
        -- Component 3: delinquent loans (0–20 pts)
        LEAST(20, (SELECT COUNT(*) FROM loans l
                   WHERE l.account_id = a.account_id AND l.status = 'DELINQUENT') * 20) AS loan_score,
        -- Component 4: account frozen (0–10 pts)
        CASE WHEN a.status = 'FROZEN' THEN 10 ELSE 0 END                 AS status_score
    FROM accounts a
    LEFT JOIN transactions t ON t.account_id = a.account_id
    GROUP BY a.account_id, a.customer_id, a.status
)
SELECT
    sc.account_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    sc.flag_score,
    sc.alert_score,
    sc.loan_score,
    sc.status_score,
    sc.flag_score + sc.alert_score + sc.loan_score + sc.status_score AS total_risk_score,
    CASE
        WHEN sc.flag_score + sc.alert_score + sc.loan_score + sc.status_score >= 50 THEN 'CRITICAL'
        WHEN sc.flag_score + sc.alert_score + sc.loan_score + sc.status_score >= 25 THEN 'HIGH'
        WHEN sc.flag_score + sc.alert_score + sc.loan_score + sc.status_score >= 10 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level
FROM score_components sc
JOIN customers c ON c.customer_id = sc.customer_id
WHERE sc.flag_score + sc.alert_score + sc.loan_score + sc.status_score > 0
ORDER BY total_risk_score DESC;


-- ------------------------------------------------------------
-- 5. Loan delinquency report with payment shortfall
-- ------------------------------------------------------------
SELECT
    l.loan_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    l.principal,
    l.interest_rate,
    l.monthly_payment,
    l.total_paid,
    l.status,
    l.start_date,
    -- Months elapsed since start
    DATE_PART('month', AGE(CURRENT_DATE, l.start_date))::INT AS months_elapsed,
    -- Expected total paid by now
    ROUND(l.monthly_payment *
          DATE_PART('month', AGE(CURRENT_DATE, l.start_date)), 2) AS expected_paid,
    -- Shortfall
    ROUND(l.monthly_payment *
          DATE_PART('month', AGE(CURRENT_DATE, l.start_date)) - l.total_paid, 2) AS payment_shortfall
FROM loans l
JOIN accounts a  ON a.account_id  = l.account_id
JOIN customers c ON c.customer_id = a.customer_id
WHERE l.status IN ('DELINQUENT','DEFAULTED')
ORDER BY payment_shortfall DESC;
