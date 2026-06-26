/*
====================================================================================
WEEK 1 - QUESTION 07: Organizational Chart Revenue Rollup
DESIGN PATTERN: Hierarchy Flattening (rCTE) + Bottom-Up Aggregation
FULL WRITEUP: Refer to /documentation/W1_Q7_Writeup.md
====================================================================================
*/

WITH PersonalRevenue AS (
    SELECT 
        e.employee_id, 
        e.employee_name, 
        e.role, 
        e.manager_id, 
        ISNULL(SUM(o.order_total), 0) AS personal_revenue
    FROM dbo.dim_employee e
    LEFT JOIN dbo.fact_orders o 
        ON e.employee_id = o.sales_rep_id 
        AND o.order_status = 'Completed'
    GROUP BY e.employee_id, e.employee_name, e.role, e.manager_id
),
HierarchyTree AS (
    SELECT 
        employee_id AS ancestor_id,
        employee_id AS descendant_id
    FROM dbo.dim_employee
    
    UNION ALL
    
    SELECT 
        ht.ancestor_id,
        e.employee_id AS descendant_id
    FROM HierarchyTree ht
    INNER JOIN dbo.dim_employee e 
        ON ht.descendant_id = e.manager_id
)
SELECT 
    pr.employee_id, 
    pr.employee_name, 
    pr.role, 
    SUM(dr.personal_revenue) AS team_total_revenue
FROM PersonalRevenue pr
INNER JOIN HierarchyTree ht 
    ON pr.employee_id = ht.ancestor_id
INNER JOIN PersonalRevenue dr 
    ON ht.descendant_id = dr.employee_id
GROUP BY pr.employee_id, pr.employee_name, pr.role
ORDER BY pr.employee_id;