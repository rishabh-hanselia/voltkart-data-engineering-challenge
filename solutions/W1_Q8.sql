/*
====================================================================================
WEEK 1 - QUESTION 08: Incremental Data Loading (CDC)
DESIGN PATTERN: Idempotent MERGE (Upsert) + Audit Logging via OUTPUT $action
FULL WRITEUP: Refer to /documentation/W1_Q8_Writeup.md
====================================================================================
*/

DECLARE @before_count INT = (SELECT COUNT(*) FROM fact_orders);

DECLARE @MergeAudit TABLE (ActionType NVARCHAR(10));

MERGE INTO dbo.fact_orders AS tgt
USING dbo.stg_orders_incr AS src
	ON tgt.order_id =src.order_id
WHEN MATCHED AND ( tgt.order_status <> src.order_status
					OR tgt.order_total <> src.order_total) THEN
	UPDATE SET tgt.order_status = src.order_status,
				tgt.order_total = src.order_total
WHEN NOT MATCHED BY TARGET THEN
	INSERT (order_id, order_date, customer_id, sales_rep_id, order_status, order_total)
	VALUES (src.order_id, src.order_date, src.customer_id, src.sales_rep_id, src.order_status, src.order_total)

OUTPUT $action INTO @MergeAudit(ActionType);

SELECT @before_count AS before_count,
       (SELECT COUNT(*) FROM fact_orders) AS after_count;

SELECT 
    ActionType, 
    COUNT(*) AS RowsAffected
FROM @MergeAudit
GROUP BY ActionType;

SELECT TOP (10) order_id, order_status, order_total
FROM fact_orders
WHERE order_id IN (SELECT order_id FROM stg_orders_incr WHERE order_id < 6500000);