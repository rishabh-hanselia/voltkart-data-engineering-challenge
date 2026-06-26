/*
====================================================================================
WEEK 1 - QUESTION 10: Query Optimization (Correlated Subquery Refactoring)
DESIGN PATTERN: Conditional Aggregation + SARGable Predicates
FULL WRITEUP: Refer to /documentation/W1_Q10_Writeup.md
====================================================================================
*/

SELECT o.customer_id, COUNT(*) AS orders_2024, 
		(SELECT SUM(oi.line_amount) 
		FROM fact_order_items oi 
			JOIN fact_orders o2 ON o2.order_id = oi.order_id 
			WHERE o2.customer_id = o.customer_id) AS lifetime_value 
FROM fact_orders o 
WHERE YEAR(o.order_date) = 2024 
GROUP BY o.customer_id;

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