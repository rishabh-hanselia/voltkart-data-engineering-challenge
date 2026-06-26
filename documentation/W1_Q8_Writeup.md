# Week 1, Question 8: Incremental Data Loading (CDC Pipeline)

## Business Context & Objective
Voltkart's nightly data pipelines were experiencing severe performance degradation due to full "drop and rebuild" table loads. The task was to refactor the pipeline to process only the daily incremental batch (`stg_orders_incr`), capturing new orders and updating the statuses of existing orders.

---

## My Engineering Approach & Design Decisions
To transition from a full-load architecture to a Change Data Capture (CDC) paradigm, I implemented an **Idempotent Upsert** pattern utilizing the T-SQL `MERGE` statement, paired with enterprise-grade audit logging.

### 1. Atomic Upsert Logic & Redundant Write Prevention
Using `MERGE` allows the database engine to handle both `INSERT` operations (new transactions) and `UPDATE` operations (mutated transactions) within a single, atomic operation. To optimize the transaction log, I added a strict boolean filter to the matched clause: `AND (tgt.order_status <> src.order_status OR tgt.order_total <> src.order_total)`. This guarantees that the storage engine only performs a physical disk write if the incoming staging data actually differs from the production target.

### 2. Comprehensive Pipeline Verification
A total row count comparison (`@before_count` vs after) is insufficient for verifying an Upsert, as updates do not alter the table's total cardinality. To mathematically prove the pipeline's success, I implemented a multi-tiered verification script:
* **Row Count Validation:** Captures the table state before and after execution to isolate the exact volume of net-new records inserted.
* **Audit Logging (`OUTPUT $action`):** I routed the `MERGE OUTPUT` clause into a table variable to generate a precise summary report showing exactly how many rows were classified as `INSERT` versus `UPDATE`.
* **Mutation Sampling:** I queried a subset of the updated IDs (keys < 6500000) directly from the target table to visually confirm that the `UPDATE` payload was successfully written to disk.