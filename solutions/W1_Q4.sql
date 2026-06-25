/*
====================================================================================
WEEK 1 - QUESTION 04: Monthly Revenue Trend & Momentum
DESIGN PATTERN: Time-Bucket Pre-Aggregation + Explicit Stream Windowing (ROWS)
FULL WRITEUP: Refer to /documentation/W1_Q4_Writeup.md
====================================================================================
*/

WITH MonthlyRevenueBase AS (
    SELECT 
        CONVERT(CHAR(7), order_date, 126) AS order_month,
        SUM(order_total) AS monthly_revenue
    FROM dbo.fact_orders
    WHERE order_status = 'Completed'
    GROUP BY CONVERT(CHAR(7), order_date, 126)
)
SELECT 
    order_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    ((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month)) / NULLIF(LAG(monthly_revenue) OVER (ORDER BY order_month), 0)) * 100 AS mom_pct_change
FROM MonthlyRevenueBase
ORDER BY order_month;