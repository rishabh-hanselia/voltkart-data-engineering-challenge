/*
====================================================================================
WEEK 1 - QUESTION 01: Top 20 Completed Orders by Value
DESIGN PATTERN: Filter Isolation (CTE) + Defensive Null Protection (LEFT JOIN)
FULL WRITEUP: Refer to /documentation/W1_Q1_Writeup.md
====================================================================================
*/

WITH CompletedOrders AS (
    SELECT order_id, order_date, customer_id, sales_rep_id, order_total
    FROM dbo.fact_orders
    WHERE order_status = 'Completed'
)
SELECT TOP 20 order_id, order_date, c.customer_name, e.employee_name AS sales_rep_name, order_total
FROM CompletedOrders co 
		LEFT JOIN dbo.dim_customer c ON co.customer_id = c.customer_id
		LEFT JOIN dbo.dim_employee e ON co.sales_rep_id = e.employee_id 
ORDER BY order_total DESC
