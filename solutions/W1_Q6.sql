/*
====================================================================================
WEEK 1 - QUESTION 06: Product Catalog Hierarchy Traversal
DESIGN PATTERN: Recursive CTE (Anchor & Recursive Members) + Path Materialization
FULL WRITEUP: Refer to /documentation/W1_Q6_Writeup.md
====================================================================================
*/

WITH ComputerCategory AS (
	SELECT category_id, category_name, parent_category_id,  1 AS depth_level, CAST(category_name AS VARCHAR(MAX)) AS category_path
	FROM dbo.dim_category
	WHERE category_name = 'Computers'

	UNION ALL

	SELECT c.category_id, c.category_name, c.parent_category_id, cccte.depth_level + 1, CAST(cccte.category_path + ' -> ' + c.category_name AS VARCHAR(MAX))
	FROM dbo.dim_category c
		INNER JOIN ComputerCategory cccte ON c.parent_category_id = cccte.category_id
		)

SELECT category_id,category_name, depth_level, category_path
FROM ComputerCategory
ORDER BY category_path;