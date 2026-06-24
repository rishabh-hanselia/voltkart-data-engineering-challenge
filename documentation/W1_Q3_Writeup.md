# Week 1, Question 3: Top 3 Products Per Category by Completed Revenue

## Business Context & Objective
The merchandising team required a visibility report to identify the top 3 revenue-generating "star" products within every distinct category across completed transactions.

---

## My Engineering Approach & Design Decisions
Rather than using a standard flat join that groups text strings across multiple tables simultaneously, I implemented a highly optimized **Pre-Aggregation Pattern** via chained Common Table Expressions (CTEs):

### 1. Pre-Aggregation to Reduce Join Density
In large-scale relational systems, grouping by heavy descriptive text strings (`product_name`, `category_name`) consumes massive amounts of temporary database memory during sorting operations. To optimize performance, my query handles all numeric aggregation (`SUM(line_amount)`) directly on the core transactional tables first, grouping strictly by the numeric `product_id` key. 

### 2. Post-Aggregation Dimension Lookup & Ranking
Once the transaction dataset was reduced down to a single row per product, I joined the descriptive metadata from `dim_product` and `dim_category`. By delaying these joins until after the aggregation phase, the query engine processes text lookups only on the unique product subset, drastically reducing logical read overhead.

### 3. Tie-Resilient Windowing via `RANK()`
I applied the `RANK() OVER (PARTITION BY ...)` window function to evaluate performance inside each isolated category branch. I chose `RANK()` over `ROW_NUMBER()` to ensure compliance with financial accounting standards—if two high-performing items generate identical revenue figures down to the rupee, they will share a tied rank rather than being cut off arbitrarily.