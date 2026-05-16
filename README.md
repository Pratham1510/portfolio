# Banking Analytics — PostgreSQL Portfolio Project

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-336791?logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A PostgreSQL project simulating a retail banking environment — covering schema design, realistic seed data, and a range of analytical SQL techniques across customer intelligence, transaction monitoring, fraud detection, and product performance.

---

## Table of Contents

- [Schema](#schema)
- [Entity-Relationship Diagram](#entity-relationship-diagram)
- [Query Modules](#query-modules)
- [SQL Techniques Demonstrated](#sql-techniques-demonstrated)
- [Getting Started](#getting-started)

---

## Schema

Six tables model a simplified retail bank:

| Table | Description |
|---|---|
| `customers` | Demographics and contact info for 30 realistic customers |
| `products` | Product catalog: checking, savings, credit cards, mortgages, loans |
| `accounts` | Customer–product link; tracks live balance, status, and credit limit |
| `transactions` | Full debit/credit ledger with `balance_after` snapshots |
| `loans` | Repayment tracking — principal, payments made, and delinquency status |
| `alerts` | Fraud and risk flags tied to accounts and individual transactions |

**Key design decisions:**

- `NUMERIC` for all monetary columns — avoids floating-point rounding errors
- `TIMESTAMPTZ` throughout — timezone-aware for multi-branch operations
- `balance_after` stored on every transaction — enables historical balance reconstruction without replaying rows
- Partial index on `transactions.is_flagged WHERE is_flagged = TRUE` — tiny index, fast fraud queries

---

## Entity-Relationship Diagram

```
customers (1) ──< accounts (many) ──< transactions
                       │
                       ├──< loans
                       │
                       └──< alerts >── transactions (optional)

accounts >── products
```

| Relationship | Cardinality |
|---|---|
| `customers` → `accounts` | One-to-many |
| `products` → `accounts` | One-to-many |
| `accounts` → `transactions` | One-to-many |
| `accounts` → `loans` | One-to-many |
| `accounts` → `alerts` | One-to-many |
| `transactions` → `alerts` | One-to-zero-or-one |

---

## Query Modules

### [Customer Insights](queries/03_customer_insights.sql)

| # | Query | Techniques |
|---|---|---|
| 1 | Customer overview — age, tenure, net balance, balance rank | CTE, `RANK()` window |
| 2 | Segmentation by age band and wealth tier | CTE, `CASE` expressions |
| 3 | Top 10 depositors with running total and % of all deposits | `RANK()`, `SUM OVER`, `NULLIF` |
| 4 | Churn risk — inactive accounts with low balance | `LEFT JOIN`, date arithmetic, `CASE` |
| 5 | Cross-sell — checking holders with no savings account | `BOOL_OR`, `HAVING`, `STRING_AGG` |

### [Transaction Analysis](queries/04_transaction_analysis.sql)

| # | Query | Techniques |
|---|---|---|
| 1 | Monthly volume and value by transaction type (last 12 months) | `ROLLUP`, `DATE_TRUNC` |
| 2 | 3-month rolling average spend per account | `AVG OVER ROWS`, `LAG`, MoM % change |
| 3 | Day-of-week spending patterns | `EXTRACT(DOW)`, `TO_CHAR` |
| 4 | Category spend with share of wallet | CTE, `RANK()`, `SUM OVER` |
| 5 | Accounts with 3+ consecutive months of balance decline | `LAG` chain, multi-condition `WHERE` |
| 6 | First and most recent transaction per account | `FIRST_VALUE`, `LAST_VALUE`, named `WINDOW` |

### [Risk & Fraud Detection](queries/05_risk_and_fraud.sql)

| # | Query | Techniques |
|---|---|---|
| 1 | Accounts with unresolved HIGH / CRITICAL alerts | `STRING_AGG`, `CASE` sort |
| 2 | Transaction velocity — 3+ transactions within any 1-hour window | Self-join, interval arithmetic |
| 3 | Round-number large transactions (structuring signal) | `MOD`, threshold filtering |
| 4 | Composite fraud risk score (weighted model) | Correlated subqueries, `LEAST`, `CASE` tiers |
| 5 | Loan delinquency report with payment shortfall | Date arithmetic, `AGE`, expected vs. actual |

### [Product Performance](queries/06_product_performance.sql)

| # | Query | Techniques |
|---|---|---|
| 1 | Product uptake — customers and penetration % per product | `NULLIF`, correlated subquery |
| 2 | Monthly account openings by product type (pivot-style) | `COUNT FILTER`, `DATE_TRUNC` |
| 3 | Revenue estimate — fees + interest income vs. expense | Multi-`CASE` revenue model |
| 4 | Loan portfolio health by status and risk tier | `GROUPING SETS`, subtotals and grand total |
| 5 | Multi-product households (cross-sell success metric) | `HAVING`, `STRING_AGG DISTINCT` |

---

## SQL Techniques Demonstrated

- **CTEs** (`WITH`) for readable multi-step logic
- **Window functions** — `ROW_NUMBER`, `RANK`, `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`, `SUM OVER`, `AVG OVER`
- **Aggregations** with `GROUPING SETS` and `ROLLUP` for subtotals
- **Correlated subqueries** inside `SELECT` and `CASE`
- **Self-joins** for pattern detection (velocity, consecutive trends)
- **Date/time arithmetic** — `AGE`, `DATE_TRUNC`, `EXTRACT`, `INTERVAL`
- **Conditional aggregation** — `COUNT FILTER`, `SUM CASE`, `BOOL_OR`
- **Fraud scoring** — weighted multi-component risk model using `LEAST` and `CASE`
- **Index design** — partial indexes, composite indexes for analytical workloads

---

## Getting Started

**Prerequisites:** PostgreSQL 14+, `psql` CLI or any SQL client (DBeaver, TablePlus, DataGrip)

```bash
# Create the database
createdb banking_analytics

# Load in order: schema → seed data → queries
psql -d banking_analytics -f schema/01_schema.sql
psql -d banking_analytics -f data/02_seed.sql

# Run any analysis module
psql -d banking_analytics -f queries/03_customer_insights.sql
psql -d banking_analytics -f queries/04_transaction_analysis.sql
psql -d banking_analytics -f queries/05_risk_and_fraud.sql
psql -d banking_analytics -f queries/06_product_performance.sql
```

---

## Project Structure

```
.
├── schema/
│   └── 01_schema.sql              # Table definitions, constraints, indexes
├── data/
│   └── 02_seed.sql                # 30 customers, accounts, 60+ transactions, loans, alerts
├── queries/
│   ├── 03_customer_insights.sql   # Segmentation, churn risk, cross-sell
│   ├── 04_transaction_analysis.sql # Time-series, rolling windows, patterns
│   ├── 05_risk_and_fraud.sql      # Velocity detection, fraud scoring
│   └── 06_product_performance.sql # Uptake, revenue, loan portfolio
└── docs/
    └── erd.md                     # Entity-relationship description
```

---

## License

MIT
