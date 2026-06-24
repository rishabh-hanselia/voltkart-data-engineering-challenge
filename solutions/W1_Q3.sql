/*
====================================================================================
WEEK 1 - QUESTION 03: Top 3 Products Per Category (Star Products)
DESIGN PATTERN: Pre-Aggregation Optimization + Window Function Ranking (RANK)
FULL WRITEUP: Refer to /documentation/W1_Q3_Writeup.md
====================================================================================
*/

WITH ProductRevenueBase AS (
    SELECT 
        oi.product_id,
        SUM(oi.line_amount) AS total_revenue
    FROM dbo.fact_order_items oi
    INNER JOIN dbo.fact_orders o 
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
),
RankedCategories AS (
    SELECT 
        c.category_name,
        p.product_name,
        pr.total_revenue,
        RANK() OVER (
            PARTITION BY p.category_id 
            ORDER BY pr.total_revenue DESC
        ) AS revenue_rank
    FROM ProductRevenueBase pr
    INNER JOIN dbo.dim_product p 
        ON pr.product_id = p.product_id
    INNER JOIN dbo.dim_category c 
        ON p.category_id = c.category_id
)
SELECT 
    category_name,
    product_name,
    total_revenue,
    revenue_rank
FROM RankedCategories
WHERE revenue_rank <= 3
ORDER BY category_name, revenue_rank;