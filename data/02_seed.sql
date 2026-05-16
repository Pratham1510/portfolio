-- =============================================================
-- Banking Analytics — Seed Data
-- =============================================================

-- -------------------------------------------------------------
-- PRODUCTS
-- -------------------------------------------------------------
INSERT INTO products (product_name, product_type, interest_rate, monthly_fee, min_balance, description) VALUES
  ('Basic Checking',        'CHECKING',      0.010, 0.00,      0,     'No-frills everyday checking account'),
  ('Premium Checking',      'CHECKING',      0.050, 12.00,     1500,  'Higher interest with waivable monthly fee'),
  ('Standard Savings',      'SAVINGS',       2.150, 0.00,      100,   'FDIC-insured savings with competitive APY'),
  ('High-Yield Savings',    'SAVINGS',       4.750, 0.00,      1000,  'Online-only high-yield savings account'),
  ('Platinum Credit Card',  'CREDIT_CARD',  19.990, 0.00,      0,     '1.5% cash back, no annual fee'),
  ('Travel Rewards Card',   'CREDIT_CARD',  22.990, 95.00,     0,     '3x points on travel and dining'),
  ('30-Yr Fixed Mortgage',  'MORTGAGE',      6.875, 0.00,      0,     '30-year fixed rate home loan'),
  ('15-Yr Fixed Mortgage',  'MORTGAGE',      6.250, 0.00,      0,     '15-year fixed rate home loan'),
  ('Personal Loan',         'PERSONAL_LOAN', 9.990, 0.00,      0,     'Unsecured personal loan up to $50,000'),
  ('Auto Loan',             'AUTO_LOAN',     5.490, 0.00,      0,     'New and used vehicle financing');

-- -------------------------------------------------------------
-- CUSTOMERS  (30 realistic records)
-- -------------------------------------------------------------
INSERT INTO customers (first_name, last_name, email, date_of_birth, gender, city, state, joined_date) VALUES
  ('James',    'Harrington', 'j.harrington@email.com',  '1978-03-14', 'M', 'Austin',       'TX', '2015-06-01'),
  ('Sofia',    'Reyes',      'sofia.reyes@email.com',   '1990-07-22', 'F', 'Miami',        'FL', '2018-02-14'),
  ('Michael',  'Chen',       'm.chen@email.com',        '1965-11-08', 'M', 'San Francisco','CA', '2010-09-30'),
  ('Priya',    'Nair',       'priya.nair@email.com',    '1985-04-17', 'F', 'Chicago',      'IL', '2019-05-20'),
  ('Ethan',    'Kowalski',   'e.kowalski@email.com',    '1992-09-03', 'M', 'Denver',       'CO', '2020-01-10'),
  ('Amelia',   'Johnson',    'a.johnson@email.com',     '1980-12-25', 'F', 'New York',     'NY', '2013-11-05'),
  ('Liam',     'Okafor',     'l.okafor@email.com',      '1998-06-11', 'M', 'Houston',      'TX', '2021-08-22'),
  ('Isabella', 'Martinez',   'i.martinez@email.com',    '1975-01-30', 'F', 'Phoenix',      'AZ', '2011-04-18'),
  ('Noah',     'Patel',      'n.patel@email.com',       '1988-08-19', 'M', 'Seattle',      'WA', '2017-07-07'),
  ('Olivia',   'Thompson',   'o.thompson@email.com',    '1995-02-28', 'F', 'Boston',       'MA', '2022-03-15'),
  ('William',  'Davis',      'w.davis@email.com',       '1960-05-05', 'M', 'Nashville',    'TN', '2008-12-01'),
  ('Emma',     'Wilson',     'e.wilson@email.com',      '1993-10-14', 'F', 'Portland',     'OR', '2019-09-09'),
  ('Oliver',   'Brown',      'o.brown@email.com',       '1982-07-07', 'M', 'Atlanta',      'GA', '2016-03-22'),
  ('Ava',      'Garcia',     'ava.garcia@email.com',    '1999-04-04', 'F', 'Las Vegas',    'NV', '2023-01-18'),
  ('Lucas',    'Anderson',   'l.anderson@email.com',    '1971-09-21', 'M', 'Minneapolis',  'MN', '2009-06-30'),
  ('Mia',      'Taylor',     'mia.taylor@email.com',    '1987-03-16', 'F', 'Charlotte',    'NC', '2018-11-11'),
  ('Henry',    'Jackson',    'h.jackson@email.com',     '1956-11-29', 'M', 'Philadelphia', 'PA', '2005-08-15'),
  ('Charlotte','White',      'c.white@email.com',       '1994-06-06', 'F', 'San Diego',    'CA', '2020-07-04'),
  ('Alexander','Harris',     'a.harris@email.com',      '1979-01-12', 'M', 'Dallas',       'TX', '2014-02-28'),
  ('Sophia',   'Martin',     's.martin@email.com',      '1991-08-08', 'F', 'Detroit',      'MI', '2021-05-01'),
  ('Daniel',   'Lee',        'd.lee@email.com',         '1984-12-31', 'M', 'Baltimore',    'MD', '2017-10-10'),
  ('Grace',    'Walker',     'g.walker@email.com',      '2000-03-03', 'F', 'Louisville',   'KY', '2022-08-20'),
  ('Samuel',   'Hall',       's.hall@email.com',        '1968-07-15', 'M', 'Memphis',      'TN', '2012-05-25'),
  ('Chloe',    'Allen',      'c.allen@email.com',       '1996-11-11', 'F', 'Oklahoma City','OK', '2023-04-01'),
  ('David',    'Young',      'd.young@email.com',       '1973-04-20', 'M', 'Richmond',     'VA', '2010-01-20'),
  ('Zoe',      'Hernandez',  'z.hernandez@email.com',   '1989-09-09', 'F', 'Sacramento',   'CA', '2019-12-12'),
  ('Joseph',   'King',       'j.king@email.com',        '1963-02-14', 'M', 'Raleigh',      'NC', '2007-03-03'),
  ('Lily',     'Wright',     'l.wright@email.com',      '1997-05-25', 'F', 'Tampa',        'FL', '2021-11-30'),
  ('Andrew',   'Scott',      'a.scott@email.com',       '1977-10-10', 'M', 'Columbus',     'OH', '2015-09-15'),
  ('Hannah',   'Green',      'h.green@email.com',       '1983-06-18', 'F', 'Indianapolis', 'IN', '2016-07-07');

-- -------------------------------------------------------------
-- ACCOUNTS
-- -------------------------------------------------------------
INSERT INTO accounts (customer_id, product_id, account_number, opened_date, status, balance, credit_limit) VALUES
-- James Harrington
  (1,  1, 'ACC000000001', '2015-06-01', 'ACTIVE',   4200.00,   NULL),
  (1,  3, 'ACC000000002', '2015-06-01', 'ACTIVE',  18500.00,   NULL),
  (1,  5, 'ACC000000003', '2016-03-10', 'ACTIVE',  -1200.00,  10000),
-- Sofia Reyes
  (2,  2, 'ACC000000004', '2018-02-14', 'ACTIVE',   7800.00,   NULL),
  (2,  4, 'ACC000000005', '2018-06-01', 'ACTIVE',  32000.00,   NULL),
-- Michael Chen
  (3,  2, 'ACC000000006', '2010-09-30', 'ACTIVE',  15400.00,   NULL),
  (3,  4, 'ACC000000007', '2012-01-15', 'ACTIVE', 142000.00,   NULL),
  (3,  6, 'ACC000000008', '2015-05-20', 'ACTIVE',  -4300.00,  20000),
-- Priya Nair
  (4,  1, 'ACC000000009', '2019-05-20', 'ACTIVE',   2100.00,   NULL),
  (4,  3, 'ACC000000010', '2019-07-01', 'ACTIVE',   9800.00,   NULL),
-- Ethan Kowalski
  (5,  1, 'ACC000000011', '2020-01-10', 'ACTIVE',    850.00,   NULL),
  (5,  5, 'ACC000000012', '2020-03-15', 'ACTIVE',  -3100.00,   8000),
-- Amelia Johnson
  (6,  2, 'ACC000000013', '2013-11-05', 'ACTIVE',  22000.00,   NULL),
  (6,  4, 'ACC000000014', '2014-02-01', 'ACTIVE',  89000.00,   NULL),
-- Liam Okafor
  (7,  1, 'ACC000000015', '2021-08-22', 'ACTIVE',   1200.00,   NULL),
-- Isabella Martinez
  (8,  2, 'ACC000000016', '2011-04-18', 'ACTIVE',  11000.00,   NULL),
  (8,  3, 'ACC000000017', '2013-06-10', 'ACTIVE',  47000.00,   NULL),
-- Noah Patel
  (9,  1, 'ACC000000018', '2017-07-07', 'ACTIVE',   3300.00,   NULL),
  (9,  3, 'ACC000000019', '2018-01-01', 'ACTIVE',  21500.00,   NULL),
-- Olivia Thompson
  (10, 1, 'ACC000000020', '2022-03-15', 'ACTIVE',    600.00,   NULL),
-- William Davis (high value)
  (11, 2, 'ACC000000021', '2008-12-01', 'ACTIVE',  45000.00,   NULL),
  (11, 4, 'ACC000000022', '2009-03-01', 'ACTIVE', 310000.00,   NULL),
  (11, 6, 'ACC000000023', '2010-06-15', 'ACTIVE',  -9800.00,  25000),
-- Emma Wilson
  (12, 1, 'ACC000000024', '2019-09-09', 'ACTIVE',   5100.00,   NULL),
  (12, 3, 'ACC000000025', '2020-01-15', 'ACTIVE',  14200.00,   NULL),
-- Ethan Kowalski (frozen account)
  (5,  3, 'ACC000000026', '2020-06-01', 'FROZEN',   4000.00,   NULL);

-- -------------------------------------------------------------
-- TRANSACTIONS  (sample — ~60 rows covering 12 months)
-- We use generate_series-style inserts for brevity.
-- -------------------------------------------------------------
INSERT INTO transactions (account_id, txn_date, txn_type, amount, balance_after, merchant, category, description) VALUES
-- Checking account 1 (James)
  (1, NOW() - INTERVAL '11 months', 'DEPOSIT',     3500.00,  3500.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '11 months' + INTERVAL '3 days', 'WITHDRAWAL', 120.00, 3380.00, 'Whole Foods', 'GROCERIES', NULL),
  (1, NOW() - INTERVAL '10 months', 'DEPOSIT',     3500.00,  6880.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '10 months' + INTERVAL '2 days', 'PAYMENT',   1800.00, 5080.00, 'Chase Mortgage','HOUSING', 'Mortgage payment'),
  (1, NOW() - INTERVAL '9 months',  'DEPOSIT',     3500.00,  8580.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '9 months'  + INTERVAL '5 days', 'WITHDRAWAL', 200.00, 8380.00, 'Shell',       'AUTO',      'Gas'),
  (1, NOW() - INTERVAL '8 months',  'DEPOSIT',     3500.00, 11880.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '7 months',  'DEPOSIT',     3500.00, 15380.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '7 months'  + INTERVAL '1 day', 'TRANSFER_OUT', 10000.00, 5380.00, NULL,        'TRANSFER',  'To savings'),
  (1, NOW() - INTERVAL '6 months',  'DEPOSIT',     3500.00,  8880.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '5 months',  'DEPOSIT',     3500.00, 12380.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '3 months',  'DEPOSIT',     3500.00, 15880.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '2 months',  'DEPOSIT',     3500.00, 19380.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '1 month',   'DEPOSIT',     3500.00, 22880.00, NULL,             'INCOME',      'Payroll deposit'),
  (1, NOW() - INTERVAL '2 weeks',   'WITHDRAWAL',   450.00, 22430.00, 'Delta Airlines', 'TRAVEL',      'Flight booking'),
-- Savings account 2 (James)
  (2, NOW() - INTERVAL '7 months',  'TRANSFER_IN', 10000.00, 10000.00, NULL,            'TRANSFER',    'From checking'),
  (2, NOW() - INTERVAL '3 months',  'INTEREST',       52.18, 10052.18, NULL,            'INTEREST',    'Monthly interest'),
  (2, NOW() - INTERVAL '2 months',  'INTEREST',       52.44, 10104.62, NULL,            'INTEREST',    'Monthly interest'),
  (2, NOW() - INTERVAL '1 month',   'INTEREST',       52.70, 10157.32, NULL,            'INTEREST',    'Monthly interest'),
-- Credit card 3 (James) — some purchases and a payment
  (3, NOW() - INTERVAL '6 months',  'PAYMENT',      500.00,  -700.00,  NULL,            'PAYMENT',     'Credit card payment'),
  (3, NOW() - INTERVAL '5 months',  'WITHDRAWAL',   349.99,  -1049.99, 'Amazon',        'SHOPPING',    'Electronics'),
  (3, NOW() - INTERVAL '4 months',  'WITHDRAWAL',   85.00,  -1134.99,  'Netflix',       'ENTERTAINMENT', NULL),
  (3, NOW() - INTERVAL '2 months',  'PAYMENT',     1000.00,  -134.99,  NULL,            'PAYMENT',     'Credit card payment'),
  (3, NOW() - INTERVAL '1 month',   'WITHDRAWAL',  1200.00, -1334.99,  'Apple Store',   'SHOPPING',    'MacBook accessories'),
  (3, NOW() - INTERVAL '1 week',    'PAYMENT',       134.99, -1200.00, NULL,            'PAYMENT',     'Credit card payment'),
-- Sofia Reyes checking (acc 4)
  (4, NOW() - INTERVAL '10 months', 'DEPOSIT',     4200.00,  4200.00, NULL,             'INCOME',      'Payroll deposit'),
  (4, NOW() - INTERVAL '10 months' + INTERVAL '5 days', 'WITHDRAWAL', 1200.00, 3000.00, 'Landlord',   'HOUSING',   'Rent'),
  (4, NOW() - INTERVAL '9 months',  'DEPOSIT',     4200.00,  7200.00, NULL,             'INCOME',      'Payroll deposit'),
  (4, NOW() - INTERVAL '9 months'  + INTERVAL '3 days', 'WITHDRAWAL', 95.00,  7105.00,  'Spotify',    'ENTERTAINMENT', NULL),
  (4, NOW() - INTERVAL '8 months',  'DEPOSIT',     4200.00, 11305.00, NULL,             'INCOME',      'Payroll deposit'),
  (4, NOW() - INTERVAL '7 months',  'DEPOSIT',     4200.00, 15505.00, NULL,             'INCOME',      'Payroll deposit'),
  (4, NOW() - INTERVAL '6 months',  'WITHDRAWAL', 10000.00,  5505.00, NULL,             'TRANSFER',   'Down payment transfer'),
  (4, NOW() - INTERVAL '5 months',  'DEPOSIT',     4200.00,  9705.00, NULL,             'INCOME',      'Payroll deposit'),
  (4, NOW() - INTERVAL '4 months',  'DEPOSIT',     4200.00, 13905.00, NULL,             'INCOME',      'Payroll deposit'),
  (4, NOW() - INTERVAL '3 months',  'DEPOSIT',     4200.00, 18105.00, NULL,             'INCOME',      'Payroll deposit'),
  (4, NOW() - INTERVAL '2 months',  'WITHDRAWAL',   350.00, 17755.00, 'Trader Joes',   'GROCERIES',   NULL),
  (4, NOW() - INTERVAL '1 month',   'DEPOSIT',     4200.00, 21955.00, NULL,             'INCOME',      'Payroll deposit'),
-- Michael Chen high-yield savings (acc 7) — interest accrual
  (7, NOW() - INTERVAL '6 months',  'INTEREST',    554.17, 135554.17, NULL,             'INTEREST',    'Monthly interest'),
  (7, NOW() - INTERVAL '5 months',  'INTEREST',    556.34, 136110.51, NULL,             'INTEREST',    'Monthly interest'),
  (7, NOW() - INTERVAL '4 months',  'INTEREST',    558.52, 136669.03, NULL,             'INTEREST',    'Monthly interest'),
  (7, NOW() - INTERVAL '3 months',  'INTEREST',    560.73, 137229.76, NULL,             'INTEREST',    'Monthly interest'),
  (7, NOW() - INTERVAL '2 months',  'INTEREST',    562.94, 137792.70, NULL,             'INTEREST',    'Monthly interest'),
  (7, NOW() - INTERVAL '1 month',   'INTEREST',    565.17, 138357.87, NULL,             'INTEREST',    'Monthly interest'),
-- Flagged / suspicious transactions
  (12, NOW() - INTERVAL '3 months', 'WITHDRAWAL', 5000.00, 5000.00,  NULL,              'TRANSFER',    'Large cash withdrawal', TRUE),
  (12, NOW() - INTERVAL '3 months' + INTERVAL '1 hour', 'WITHDRAWAL', 5000.00, 0.00, NULL, 'TRANSFER', 'Large cash withdrawal', TRUE),
  (8,  NOW() - INTERVAL '1 month',  'WITHDRAWAL', 9999.00,-14299.00,  NULL,             'SHOPPING',    'Unusual large purchase', TRUE),
  (11, NOW() - INTERVAL '45 days',  'DEPOSIT',   50000.00, 95000.00, NULL,             'INCOME',       'Large deposit - verify source', TRUE),
-- William Davis premium (acc 21)
  (21, NOW() - INTERVAL '12 months','DEPOSIT',    12000.00, 12000.00, NULL,             'INCOME',      'Consulting payment'),
  (21, NOW() - INTERVAL '9 months', 'DEPOSIT',    15000.00, 27000.00, NULL,             'INCOME',      'Consulting payment'),
  (21, NOW() - INTERVAL '6 months', 'DEPOSIT',    18000.00, 45000.00, NULL,             'INCOME',      'Q2 bonus'),
  (21, NOW() - INTERVAL '3 months', 'TRANSFER_OUT',5000.00, 40000.00, NULL,             'TRANSFER',    'To high-yield savings'),
  (21, NOW() - INTERVAL '1 month',  'WITHDRAWAL',  2500.00, 37500.00, 'Tiffany & Co', 'SHOPPING',     'Gift purchase');

-- -------------------------------------------------------------
-- LOANS
-- -------------------------------------------------------------
INSERT INTO loans (account_id, principal, interest_rate, term_months, start_date, end_date, monthly_payment, total_paid, status) VALUES
  (3,  15000.00, 9.990,  48, '2022-01-01', '2025-12-31',  379.98,  9119.52, 'CURRENT'),
  (8,  30000.00, 9.990,  60, '2021-06-01', '2026-05-31',  637.80, 30422.40, 'CURRENT'),
  (12,  8000.00, 12.990, 36, '2023-03-01', '2026-02-28',  268.93,  3226.16, 'CURRENT'),
  (16, 250000.00, 6.875, 360,'2011-05-01', '2041-04-30', 1641.83, 250758.78,'CURRENT'),
  (22, 480000.00, 6.250, 180,'2009-04-01', '2024-03-31', 4114.36, 740584.80,'PAID_OFF'),
  (15,  5000.00, 14.990, 24, '2022-09-01', '2024-08-31',  242.44,  5818.56, 'PAID_OFF'),
  (20,  3500.00, 18.990, 24, '2023-01-01', '2024-12-31',  176.08,    528.24,'DELINQUENT');

-- -------------------------------------------------------------
-- ALERTS
-- -------------------------------------------------------------
INSERT INTO alerts (account_id, transaction_id, alert_type, severity, resolved, notes) VALUES
  (12, 47, 'VELOCITY_BREACH',       'HIGH',     FALSE, 'Two $5,000 withdrawals within 1 hour'),
  (12, 48, 'VELOCITY_BREACH',       'HIGH',     FALSE, 'Duplicate large withdrawal pattern'),
  (8,  49, 'LARGE_TRANSACTION',     'MEDIUM',   TRUE,  'Resolved after customer verification'),
  (11, 50, 'UNUSUAL_DEPOSIT',       'MEDIUM',   FALSE, 'Awaiting source-of-funds documentation'),
  (26, NULL,'DORMANT_ACCOUNT_ACTIVITY','LOW',   TRUE,  'Account frozen pending review'),
  (20, NULL,'DELINQUENT_LOAN',      'CRITICAL', FALSE, 'Loan 90+ days past due');
