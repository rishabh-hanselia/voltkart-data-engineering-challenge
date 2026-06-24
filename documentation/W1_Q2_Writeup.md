# Week 1, Question 2: Inactive Customer Identification

## Business Context & Objective
The marketing team required a targeted re-engagement list identifying all registered Voltkart customers who have signed up on the platform but have never placed a single order.

---

## My Engineering Approach & Design Decisions
To extract this dataset efficiently, I utilized an existential anti-join pattern via **`NOT EXISTS`** rather than a traditional `NOT IN` subquery or a `LEFT JOIN / IS NULL` approach.

### 1. Immunity to Unintended NULL Propagation
In T-SQL, a `NOT IN` predicate operates under Strict ANSI SQL standards. If the subquery table (`fact_orders`) contains even a single `NULL` in the joining column (`customer_id`), the entire `NOT IN` condition evaluates to `UNKNOWN`. This causes the query to silently fail and return an empty result set. 
By utilizing `NOT EXISTS`, the condition explicitly evaluates whether a matching row exists or not, rendering the query fully resilient against nullable foreign keys in the fact table.

### 2. Optimizer Efficiency & Short-Circuit Evaluation
From a physical execution standpoint, SQL Server processes `NOT EXISTS` by executing a **Left Anti Semi Join**. Unlike a full join or an explicit subquery aggregation, the storage engine does not scan the entire transaction table for each user. Instead, it utilizes "short-circuit" logic—the exact moment it encounters the first matching transaction for a `customer_id`, it drops that customer from evaluation and immediately advances to the next record. This dramatically minimizes logical memory allocation and CPU overhead on large datasets.