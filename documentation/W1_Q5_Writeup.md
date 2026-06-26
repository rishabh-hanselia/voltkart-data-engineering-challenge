# Week 1, Question 5: Customer Segmentation by Value Quartiles

## Business Context & Objective

The objective of this query was to segment customers into four value-based groups using their lifetime completed order spend. This helps the business understand how customers are distributed across spending levels and compare the average customer value within each quartile.

---

## My Engineering Approach & Design Decisions

I structured the query in stages so that each part of the logic had a clear responsibility: first calculating customer-level lifetime spend, then assigning quartiles, and finally summarising the results at the quartile level.

### 1. Building the Customer-Level Spend Base (`CustomerLifeSpends`)

The first step was to calculate each customer’s total lifetime spend using the `fact_orders` table. I only included orders where `order_status = 'Completed'` because the segmentation should be based on actual realised sales, not orders that may still be pending, cancelled, or otherwise not final.

This gives a clean customer-level base where each customer has one lifetime spend value.

### 2. Segmenting Customers Using Quartiles (`CustomerQuartile`)

After calculating lifetime spend, I used `NTILE(4)` to divide customers into four groups based on spend. I chose this approach because the requirement was to create balanced customer segments, not fixed monetary ranges.

Using fixed spend ranges could create uneven groups if a few customers spend much more than the rest. By using quartiles, the query groups customers by their relative position in the spend distribution, making the output more useful for comparing low, mid, and high-value customer groups.

Since the ordering is ascending, Quartile 1 represents the lowest-spending customers, while Quartile 4 represents the highest-spending customers.

### 3. Summarising Quartile-Level Insights

In the final step, I grouped the customers by their assigned quartile and calculated two key outputs: the number of customers in each quartile and the average lifetime spend for that quartile.

This final result gives a concise view of customer value distribution, showing both how many customers fall into each segment and how valuable each segment is on average.
::: 
