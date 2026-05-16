-- =============================================================
-- Banking Analytics — Schema
-- PostgreSQL 14+
-- =============================================================

-- Clean slate (safe for re-runs)
DROP TABLE IF EXISTS alerts      CASCADE;
DROP TABLE IF EXISTS loans       CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS accounts    CASCADE;
DROP TABLE IF EXISTS products    CASCADE;
DROP TABLE IF EXISTS customers   CASCADE;

-- -------------------------------------------------------------
-- CUSTOMERS
-- -------------------------------------------------------------
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(120) NOT NULL UNIQUE,
    date_of_birth   DATE         NOT NULL,
    gender          CHAR(1)      CHECK (gender IN ('M','F','X')),
    city            VARCHAR(80),
    state           CHAR(2),
    joined_date     DATE         NOT NULL DEFAULT CURRENT_DATE,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE
);

-- -------------------------------------------------------------
-- PRODUCTS  (savings, checking, credit card, mortgage, etc.)
-- -------------------------------------------------------------
CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    product_type    VARCHAR(30)  NOT NULL
                    CHECK (product_type IN ('SAVINGS','CHECKING','CREDIT_CARD','MORTGAGE','PERSONAL_LOAN','AUTO_LOAN')),
    interest_rate   NUMERIC(5,3),          -- annual %
    monthly_fee     NUMERIC(8,2) DEFAULT 0,
    min_balance     NUMERIC(12,2) DEFAULT 0,
    description     TEXT
);

-- -------------------------------------------------------------
-- ACCOUNTS  (one customer can hold multiple accounts)
-- -------------------------------------------------------------
CREATE TABLE accounts (
    account_id      SERIAL PRIMARY KEY,
    customer_id     INT          NOT NULL REFERENCES customers(customer_id),
    product_id      INT          NOT NULL REFERENCES products(product_id),
    account_number  CHAR(12)     NOT NULL UNIQUE,
    opened_date     DATE         NOT NULL DEFAULT CURRENT_DATE,
    closed_date     DATE,
    status          VARCHAR(15)  NOT NULL DEFAULT 'ACTIVE'
                    CHECK (status IN ('ACTIVE','CLOSED','FROZEN','DORMANT')),
    balance         NUMERIC(14,2) NOT NULL DEFAULT 0.00,
    credit_limit    NUMERIC(14,2)           -- for credit cards
);

CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_accounts_status   ON accounts(status);

-- -------------------------------------------------------------
-- TRANSACTIONS
-- -------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id  BIGSERIAL    PRIMARY KEY,
    account_id      INT          NOT NULL REFERENCES accounts(account_id),
    txn_date        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    txn_type        VARCHAR(20)  NOT NULL
                    CHECK (txn_type IN ('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT',
                                        'PAYMENT','REFUND','FEE','INTEREST')),
    amount          NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    balance_after   NUMERIC(14,2) NOT NULL,
    merchant        VARCHAR(100),
    category        VARCHAR(50),
    description     TEXT,
    is_flagged      BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_txn_account  ON transactions(account_id);
CREATE INDEX idx_txn_date     ON transactions(txn_date DESC);
CREATE INDEX idx_txn_flagged  ON transactions(is_flagged) WHERE is_flagged = TRUE;

-- -------------------------------------------------------------
-- LOANS
-- -------------------------------------------------------------
CREATE TABLE loans (
    loan_id         SERIAL       PRIMARY KEY,
    account_id      INT          NOT NULL REFERENCES accounts(account_id),
    principal       NUMERIC(14,2) NOT NULL,
    interest_rate   NUMERIC(5,3) NOT NULL,
    term_months     INT          NOT NULL,
    start_date      DATE         NOT NULL,
    end_date        DATE         NOT NULL,
    monthly_payment NUMERIC(12,2) NOT NULL,
    total_paid      NUMERIC(14,2) NOT NULL DEFAULT 0,
    status          VARCHAR(15)  NOT NULL DEFAULT 'CURRENT'
                    CHECK (status IN ('CURRENT','PAID_OFF','DEFAULTED','DELINQUENT'))
);

-- -------------------------------------------------------------
-- ALERTS  (fraud / risk flags)
-- -------------------------------------------------------------
CREATE TABLE alerts (
    alert_id        SERIAL       PRIMARY KEY,
    account_id      INT          NOT NULL REFERENCES accounts(account_id),
    transaction_id  BIGINT       REFERENCES transactions(transaction_id),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    alert_type      VARCHAR(40)  NOT NULL,
    severity        VARCHAR(10)  NOT NULL CHECK (severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    resolved        BOOLEAN      NOT NULL DEFAULT FALSE,
    notes           TEXT
);
