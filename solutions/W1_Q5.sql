/*
====================================================================================
WEEK 1 - QUESTION 05: Customer Segmentation by Value Quartiles
DESIGN PATTERN: Chained Pre-Aggregation + Statistical Distribution Windowing (NTILE)
FULL WRITEUP: Refer to /documentation/W1_Q5_Writeup.md
====================================================================================
*/

WITH CustomerLifeSpends AS(
	SELECT customer_id, SUM(order_total) AS lifetime_spends
	FROM dbo.fact_orders
	WHERE order_status = 'Completed'
	GROUP BY customer_id
	),
	CustomerQuartile AS(
	SELECT customer_id, lifetime_spends,
		NTILE(4) OVER (ORDER BY lifetime_spends ASC) AS spend_quartile
	FROM CustomerLifeSpends
	)
SELECT spend_quartile,COUNT(customer_id) AS customer_count, AVG(lifetime_spends) AS avg_lifetime_spend
FROM CustomerQuartile
GROUP BY spend_quartile
ORDER BY spend_quartile;


