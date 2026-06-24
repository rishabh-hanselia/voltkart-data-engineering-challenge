# Week 1, Question 1: Top 20 Completed Orders by Value

## Business Context & Objective
The commercial team required a quick look at Voltkart's biggest transactions, pulling the top 20 completed orders alongside customer and sales representative details.

---

## My Engineering Approach & Design Decisions
While the baseline hint suggests using standard `INNER JOIN`s across the schema, I deliberately chose a more robust and defensive engineering pattern using a **Common Table Expression (CTE)** and **`LEFT JOIN`s**:

### 1. Explicit Predicate Isolation via CTE
The core requirement dictates that only orders with an `order_status = 'Completed'` should be considered. Instead of relying blindly on the SQL Server Query Optimizer to handle predicate pushdown, I isolated the business filtering logic into a CTE named `CompletedOrders`. This ensures that we explicitly prune out all Cancelled or Returned orders before any dimension matching occurs.

### 2. Defensive Data Integrity using LEFT JOIN
In production environments, data pipelines can suffer from structural inconsistencies, such as orphaned foreign keys or deleted dimension records. Using an `INNER JOIN` poses a risk: if a high-value order lacks a corresponding record in `dim_customer` or `dim_employee`, that multi-million rupee transaction would completely vanish from the commercial report.

By pairing the CTE with a `LEFT JOIN`, I protected the integrity of the fact table rows. If a data inconsistency exists, the query will still accurately surface the transaction's revenue and ID, outputting a `NULL` for the missing dimension detail rather than dropping critical financial data entirely.