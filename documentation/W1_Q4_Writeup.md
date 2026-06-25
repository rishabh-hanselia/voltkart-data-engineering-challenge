# Week 1, Question 4: Monthly Completed Revenue Trend with Momentum

## Business Context & Objective
The Finance team required a trend report displaying monthly completed revenue alongside a cumulative running total and a month-over-month (MoM) performance growth percentage.

---

## My Engineering Approach & Design Decisions
I broke this challenge down into a two-step pipeline using a Pre-Aggregation CTE to calculate monthly baselines before layering the final window metrics.

### 1. Deterministic Date Bucketing
To isolate transactions cleanly into monthly buckets, I used `CONVERT(CHAR(7), order_date, 126)`. This safely formats the dates into a standardized `YYYY-MM` string without relying on fragile string concatenation, ensuring the rows group and sort perfectly.

### 2. Optimizing the Running Total with Explicit `ROWS`
When writing the cumulative running total, I deliberately added the `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` frame clause. I chose this to explicitly bypass SQL Server's default `RANGE` behavior. Because `RANGE` unnecessarily spools data to `tempdb` and hurts execution speed, forcing a `ROWS` frame ensures the running total streams efficiently in memory.

### 3. Defensive Math for Month-over-Month Growth
For the MoM percentage growth calculation, I used `LAG()` to pull the previous month's revenue. To make the code production-grade, I wrapped the denominator in a `NULLIF(..., 0)` function. This prevents the entire query from crashing due to a divide-by-zero error on the very first month of data where no prior baseline exists.