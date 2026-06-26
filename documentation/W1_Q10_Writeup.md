# Week 1, Question 10: Query Optimization (Correlated Subquery Refactoring)

## Business Context & Objective
The existing query used to generate a customer report (showing 2024 order counts alongside total lifetime value) was experiencing severe performance degradation. The objective was to rewrite the logic to minimize logical reads and execution time.

---

## My Engineering Approach & Design Decisions

### 1. Eliminating the Correlated Subquery
The original query utilized a correlated subquery in the `SELECT` statement to calculate lifetime value from `fact_order_items`. This forced the database engine into a row-by-row execution (RBAR) trap. I refactored the query to utilize the pre-aggregated `order_total` column directly on `fact_orders`, flattening the query and removing the need for an expensive, redundant join.

### 2. SARGable Date Filtering
The original code filtered dates using `YEAR(order_date) = 2024`. Wrapping a column in a function prevents the SQL optimizer from utilizing indexes (a non-SARGable predicate). I replaced this with explicit boundary checks (`order_date >= '2024-01-01' AND order_date < '2025-01-01'`), ensuring index seeks can occur.

### 3. Conditional Aggregation (Single-Scan Optimization)
Instead of querying the table twice (once for 2024 counts, once for lifetime sums), I utilized Conditional Aggregation. By embedding a `CASE WHEN` statement inside the `COUNT` function, the SQL engine only has to scan the `fact_orders` table a single time, accurately calculating both the constrained 2024 count and the unconstrained lifetime sum simultaneously. A `HAVING` clause ensures the final output strictly mirrors the original query's logic by only returning customers active in 2024.