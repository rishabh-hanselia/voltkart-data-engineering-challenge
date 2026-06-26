# Week 1, Question 9: Full CDC Dimension Synchronization

## Business Context & Objective
The data engineering team needed to synchronize the target `dim_product` dimension table with upstream source system changes via a Change Data Capture (CDC) payload (`cdc_product_changes`). The payload includes explicit operation flags indicating whether a product was inserted (`I`), updated (`U`), or deleted (`D`).

---

## My Engineering Approach & Design Decisions
To process all three data mutations efficiently without relying on sequential, multi-step staging queries, I implemented a comprehensive **3-Way MERGE Statement** followed by strict state-verification querying.

### 1. Conditional Action Branches
By leveraging the CDC `operation` flag directly inside the `MATCHED` and `NOT MATCHED` clauses, the SQL engine routes every row to its correct DML operation within a single pass over the data:
* **`U` (Updates):** Overwrites existing dimensional attributes with fresh source data.
* **`D` (Deletes):** Executes a physical hard delete on the target table to mirror the source system's state. Because the `MERGE` statement inherently binds the target and source rows via the `ON` clause, the `DELETE` action executes cleanly without requiring redundant `WHERE` filtering.
* **`I` (Inserts):** Maps net-new products into the target table, explicitly passing the source `product_id` to maintain key parity between systems.

### 2. State-Based Verification Validation
Rather than relying on generic row counts or system timestamp columns (`updatedAt`), I engineered a three-tier verification suite that physically proves the pipeline's success by comparing the target's post-execution state directly against the CDC feed:
* **Insert Validation:** Queries the dimension table for the newly ingested IDs to prove physical presence.
* **Update Validation:** Joins the updated production rows back to the staging feed to demonstrate that the `price_now` perfectly mirrors the `price_from_feed`.
* **Delete Validation:** Attempts to query the deleted IDs from the production table, expecting a strict `0 rows` return to prove successful data purging.