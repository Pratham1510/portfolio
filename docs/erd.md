# Entity-Relationship Description

## Tables & Relationships

```
customers (1) ──< accounts (1) ──< transactions
                       │
                       ├──< loans
                       │
                       └──< alerts >── transactions (optional FK)

accounts >── products
```

## Cardinalities

| Relationship | Cardinality |
|---|---|
| `customers` → `accounts` | One-to-many |
| `products` → `accounts` | One-to-many |
| `accounts` → `transactions` | One-to-many |
| `accounts` → `loans` | One-to-many |
| `accounts` → `alerts` | One-to-many |
| `transactions` → `alerts` | One-to-zero-or-one |

## Key Design Decisions

- **`balance` stored on `accounts`** — denormalised for query performance; updated by application logic on every transaction.
- **`balance_after` on `transactions`** — point-in-time snapshot enables historical balance reconstruction without replaying all rows.
- **Partial index on `transactions.is_flagged`** — only indexes the minority TRUE rows, keeping the index small and fast.
- **`TIMESTAMPTZ` for all timestamps** — timezone-aware to support customers and branches across time zones.
- **`NUMERIC` for all monetary values** — avoids floating-point rounding errors that `FLOAT` would introduce.
