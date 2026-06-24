/*
====================================================================================
WEEK 1 - QUESTION 02: Inactive Customer Identification (Marketing Re-engagement)
DESIGN PATTERN: Existential Anti-Join (NOT EXISTS)
FULL WRITEUP: Refer to /documentation/W1_Q2_Writeup.md
====================================================================================
*/

SELECT customer_id, customer_name, signup_date
FROM dbo.dim_customer c
WHERE NOT EXISTS (
		SELECT 1
		FROM dbo.fact_orders o 
		WHERE o.customer_id = c.customer_id
		);