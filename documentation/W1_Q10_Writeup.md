# Week 1, Question 10: Query Optimization (Correlated Subquery)

## Business Context & Objective

The existing query used to generate a customer report was experiencing severe performance degradation. The objective was to use execution plans and `STATISTICS IO` to identify the bottleneck, rewrite the query, and apply indexing to optimize performance.

---

## 1. The Baseline Before Optimization

### Original Query

```sql
SELECT 
    o.customer_id, 
    COUNT(*) AS orders_2024, 
    (
        SELECT SUM(oi.line_amount) 
        FROM fact_order_items oi 
        JOIN fact_orders o2 
            ON o2.order_id = oi.order_id 
        WHERE o2.customer_id = o.customer_id
    ) AS lifetime_value 
FROM fact_orders o 
WHERE YEAR(o.order_date) = 2024 
GROUP BY o.customer_id;
```

### Execution Plan & Statistics Before Optimization

The original query's execution plan revealed a major bottleneck caused by the correlated subquery in the `SELECT` clause. The query used a `Nested Loops (Inner Join)` operator, meaning that for every customer found in 2024, the engine had to repeatedly calculate the lifetime value.

This created Row-By-Agonizing-Row (RBAR) processing, which is inefficient at scale.

Another issue was the use of:

```sql
YEAR(o.order_date) = 2024
```

This is a non-SARGable predicate because the function is applied directly to the column. As a result, SQL Server could not efficiently seek on the date column and had to perform a scan instead.

### Statistics Before Optimization

| Metric                              | Value |
| ----------------------------------- | ----: |
| Logical Reads on `fact_order_items` |   267 |
| Logical Reads on `fact_orders`      |   386 |
| CPU Time                            | 31 ms |

---

## 2. The Solution: Indexing & Rewriting

To fix the performance issue, I implemented two major changes.

### 2.1 Covering Index

I created a nonclustered index to give the query engine a lightweight and sorted access path to the required data without needing to repeatedly touch the underlying clustered index.

```sql
CREATE NONCLUSTERED INDEX IX_fact_orders_customer_date 
ON dbo.fact_orders (customer_id, order_date)
INCLUDE (order_total, order_id);
```

This index supports grouping by `customer_id`, filtering by `order_date`, and calculating the lifetime value using `order_total`.

### 2.2 Conditional Aggregation

I removed the correlated subquery entirely.

Since `fact_orders` already contains the `order_total` column, I calculated both the 2024 order count and the lifetime value in a single pass over `fact_orders`.

I also replaced the non-SARGable `YEAR(order_date)` condition with SARGable date boundaries:

```sql
order_date >= '2024-01-01' 
AND order_date < '2025-01-01'
```

This allows SQL Server to use the index more efficiently.

---

## 3. The Optimized Pipeline After Optimization

### Rewritten Query

```sql
SELECT 
    customer_id,
    COUNT(CASE 
        WHEN order_date >= '2024-01-01' 
         AND order_date < '2025-01-01' 
        THEN order_id 
    END) AS orders_2024,
    SUM(order_total) AS lifetime_value
FROM dbo.fact_orders
GROUP BY customer_id
HAVING COUNT(CASE 
    WHEN order_date >= '2024-01-01' 
     AND order_date < '2025-01-01' 
    THEN order_id 
END) > 0;
```

### Execution Plan & Statistics After Optimization

After the rewrite, the execution plan became much cleaner. The engine no longer needed to run the correlated subquery repeatedly. Instead, it was able to process the data in a single scan of the new nonclustered index and use a more efficient aggregation strategy.

The `fact_order_items` table was completely removed from the query because the required lifetime value could be calculated directly from `fact_orders.order_total`.

### Statistics After Optimization

| Metric                              | Value |
| ----------------------------------- | ----: |
| Logical Reads on `fact_order_items` |     0 |
| Logical Reads on `fact_orders`      |   127 |
| CPU Time                            | 15 ms |

---

## 4. Final Result

The optimized query reduced unnecessary table access, removed the correlated subquery, and replaced the non-SARGable date filter with an index-friendly condition.

Overall, the optimization achieved:

* Complete elimination of reads from `fact_order_items`
* Reduced logical reads on `fact_orders` from 386 to 127
* Reduced CPU time from 31 ms to 15 ms
* A cleaner execution plan with no repeated correlated subquery execution
