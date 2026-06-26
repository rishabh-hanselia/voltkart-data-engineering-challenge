# Week 1, Question 7: Organizational Chart Revenue Rollup

## Business Context & Objective
The executive team required a full organizational chart rollup, detailing the total "team revenue" for every employee. This metric must include the employee's direct personal sales plus the cumulative sales of every descendant reporting to them down the corporate tree.

---

## My Engineering Approach & Design Decisions
Calculating bottom-up hierarchical rollups directly inside a single Recursive CTE (rCTE) often results in erroneous top-down accumulation (passing the CEO's revenue down to subordinates). To ensure mathematical accuracy, I engineered a **Hierarchy Flattening Pipeline**.

### 1. Isolation of Personal Baselines
First, I aggregated the individual, direct sales for every employee into a base CTE (`PersonalRevenue`), strictly filtering for `Completed` orders. Utilizing `ISNULL(..., 0)` paired with a `LEFT JOIN` guarantees that employees with zero direct sales (such as upper management) remain in the dataset for structural integrity.

### 2. Hierarchy Flattening via rCTE
Instead of accumulating math inside the recursive loop, I utilized the rCTE strictly as a structural mapping tool. The anchor member establishes that every employee is an ancestor to themselves. The recursive member walks down the `manager_id` chain, resulting in a flattened lookup table (`HierarchyTree`) that maps every leader to a comprehensive list of all their direct and indirect descendants.

### 3. Bottom-Up Aggregation
In the final output query, I joined the core employee list to the `HierarchyTree`, and then joined back to the `PersonalRevenue` table to retrieve the metrics for the descendants. A simple `SUM` aggregation grouped by the top-level ancestor successfully rolls up the revenue from the bottom of the tree to the top, fully satisfying the business requirement.