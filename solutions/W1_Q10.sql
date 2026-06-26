/*
====================================================================================
WEEK 1 - QUESTION 10: Query Optimization (Correlated Subquery Refactoring)
DESIGN PATTERN: Indexing + Conditional Aggregation + Execution Plan Analysis
FULL WRITEUP: Refer to /documentation/W1_Q10_Writeup.md
====================================================================================
*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT '====================================================================';
PRINT 'EXECUTING BASELINE (ORIGINAL) QUERY...';
PRINT '====================================================================';

SELECT 
    o.customer_id, 
    COUNT(*) AS orders_2024, 
    (SELECT SUM(oi.line_amount) 
     FROM dbo.fact_order_items oi 
     JOIN dbo.fact_orders o2 ON o2.order_id = oi.order_id 
     WHERE o2.customer_id = o.customer_id) AS lifetime_value 
FROM dbo.fact_orders o 
WHERE YEAR(o.order_date) = 2024 
GROUP BY o.customer_id;

PRINT '====================================================================';
PRINT 'APPLYING OPTIMIZATION (CREATING COVERING INDEX)...';
PRINT '====================================================================';

CREATE NONCLUSTERED INDEX IX_fact_orders_customer_date 
ON dbo.fact_orders (customer_id, order_date)
INCLUDE (order_total, order_id);

PRINT '====================================================================';
PRINT 'EXECUTING OPTIMIZED QUERY...';
PRINT '====================================================================';

SELECT 
    customer_id,
    COUNT(CASE 
        WHEN order_date >= '2024-01-01' AND order_date < '2025-01-01' THEN order_id 
    END) AS orders_2024,
    SUM(order_total) AS lifetime_value
FROM dbo.fact_orders
GROUP BY customer_id
HAVING COUNT(CASE 
    WHEN order_date >= '2024-01-01' AND order_date < '2025-01-01' THEN order_id 
END) > 0; 

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
