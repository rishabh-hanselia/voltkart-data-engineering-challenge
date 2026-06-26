# Week 1, Question 6: Product Catalog Hierarchy Traversal

## Business Context & Objective
The merchandising team required a flattened, human-readable map of the product catalog tree starting specifically from the 'Computers' root category. They needed to see the exact lineage path and depth level of every sub-category beneath it.

---

## My Engineering Approach & Design Decisions
To traverse the parent-child relationships inside the `dim_category` table, I implemented a **Recursive Common Table Expression (rCTE)** to dynamically unroll the hierarchy.

### 1. The Anchor Member Initialization
The CTE begins with the anchor query, acting as the root node. I explicitly filtered for `category_name = 'Computers'` to set the exact starting point. Here, I initialized the `depth_level` to 1.

### 2. Defensive String Type Casting
A critical design decision in this query is the explicit type casting of the lineage path: `CAST(category_name AS VARCHAR(MAX)) AS category_path`. In SQL Server, the data types and lengths of the recursive member must strictly match the anchor member. If left uncast, SQL Server would lock the column length to the exact character count of the word 'Computers'. When the recursive loop attempts to append longer child paths (e.g., 'Computers -> Laptops -> Gaming'), it would trigger a hard truncation failure. Casting to `VARCHAR(MAX)` protects the pipeline against hierarchy scaling.

### 3. The Recursive Loop & Path Materialization
The second half of the `UNION ALL` joins the raw `dim_category` table back onto the CTE itself, linking each child's `parent_category_id` to the parent's `category_id`. With every loop iteration, the `depth_level` increments by 1, and the current child's name is concatenated onto the materialized `category_path` string using a visual `->` delimiter. Finally, ordering the output by this materialized path naturally groups the tree branches together in the final report.