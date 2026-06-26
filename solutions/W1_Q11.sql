/*
====================================================================================
WEEK 1 - QUESTION 11 (BONUS): Customer Loyalty Streaks (Consecutive Months)
DESIGN PATTERN: Gaps & Islands (Row Number Subtraction Method)
FULL WRITEUP: Refer to /documentation/W1_Q11_Writeup.md
====================================================================================
*/

WITH DistinctActiveMonths AS (
    SELECT DISTINCT 
        o.customer_id, 
        c.customer_name,
        DATEDIFF(MONTH, '2000-01-01', o.order_date) AS month_int
    FROM dbo.fact_orders o
    INNER JOIN dbo.dim_customer c 
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'Completed'
),
StreakGrouping AS (
    SELECT 
        customer_id,
        customer_name,
        month_int,
        month_int - ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY month_int ASC) AS streak_group
    FROM DistinctActiveMonths
),
StreakLengths AS (
    SELECT 
        customer_id,
        customer_name,
        streak_group,
        COUNT(month_int) AS streak_months
    FROM StreakGrouping
    GROUP BY customer_id, customer_name, streak_group
)
SELECT 
    customer_id,
    customer_name,
    MAX(streak_months) AS longest_streak_months
FROM StreakLengths
GROUP BY customer_id, customer_name
ORDER BY longest_streak_months DESC, customer_id;