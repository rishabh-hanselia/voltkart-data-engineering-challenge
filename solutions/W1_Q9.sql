/*
====================================================================================
WEEK 1 - QUESTION 09: Full CDC Dimension Sync (Insert, Update, Delete)
DESIGN PATTERN: 3-Way MERGE + Audit Logging
FULL WRITEUP: Refer to /documentation/W1_Q9_Writeup.md
====================================================================================
*/

DECLARE @before_count INT = (SELECT COUNT(*) FROM dbo.dim_product);
DECLARE @MergeAudit TABLE (ActionType NVARCHAR(10));

MERGE INTO dbo.dim_product as tgt
USING dbo.cdc_product_changes as src
	ON tgt.product_id = src.product_id
	WHEN MATCHED AND (src.operation = 'U') THEN
	UPDATE SET tgt. product_name = src.product_name,
				tgt. category_id = src.category_id,
				tgt.unit_price = src.unit_price,
				tgt.unit_cost = src.unit_cost,
				tgt.launch_date = src.launch_date
	WHEN MATCHED AND (src.operation = 'D') THEN
	DELETE 
	WHEN NOT MATCHED BY TARGET AND (src.operation ='I') THEN
	INSERT(product_id, product_name, category_id, unit_price, unit_cost, launch_date)
	VALUES(src.product_id, src.product_name, src.category_id, src.unit_price, src.unit_cost, src.launch_date)
OUTPUT $action INTO @MergeAudit(ActionType);

SELECT 
    @before_count AS before_count,       
    (SELECT COUNT(*) FROM dbo.dim_product) AS after_count;

SELECT 
    ActionType, 
    COUNT(*) AS RowsAffected
FROM @MergeAudit
GROUP BY ActionType;

SELECT * FROM dbo.dim_product
WHERE product_id IN (
    SELECT product_id 
    FROM dbo.cdc_product_changes 
    WHERE operation = 'I'
);

SELECT 
    p.product_id, 
    p.unit_price AS price_now, 
    c.unit_price AS price_from_feed
FROM dbo.dim_product p
INNER JOIN dbo.cdc_product_changes c 
    ON c.product_id = p.product_id
WHERE c.operation = 'U';

SELECT product_id 
FROM dbo.cdc_product_changes
WHERE operation = 'D' 
  AND product_id IN (SELECT product_id FROM dbo.dim_product);