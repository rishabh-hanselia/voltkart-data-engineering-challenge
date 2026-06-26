# Week 1, Question 11 (Bonus): Customer Loyalty Streaks

## Business Context & Objective
The retention team required a metric to identify highly loyal customers by calculating their "longest streak." Specifically, the pipeline needed to evaluate historical data and find the maximum number of consecutive calendar months in which a customer placed at least one completed order.

---

## My Engineering Approach & Design Decisions
Calculating consecutive temporal events in a relational database requires resolving the classic **"Gaps and Islands"** problem. I utilized the `ROW_NUMBER()` subtraction method to isolate contiguous blocks of time.

### 1. Temporal Normalization
First, I needed to flatten the data so that multiple orders in the same month didn't artificially inflate the sequence. I used a `SELECT DISTINCT` alongside `DATEDIFF(MONTH, '2000-01-01', order_date)`. This converts the standard datetime into a dense, sequential integer representing the calendar month (e.g., January 2024 = 288, February 2024 = 289), providing a perfect mathematical baseline.

### 2. The Gaps and Islands Algorithm
In the `StreakGrouping` CTE, I generated a `ROW_NUMBER()` ordered chronologically for each customer. By subtracting this row number from the sequential `month_int`, the query produces a constant integer for any contiguous sequence. The moment a customer skips a month (a gap), the `month_int` jumps, but the `ROW_NUMBER()` only increments by 1, resulting in a brand new constant integer (a new island). 

### 3. Aggregation & Maximization
With every streak now possessing a unique `streak_group` identifier, I grouped the data to simply `COUNT()` the number of months inside each island. Finally, a top-level aggregation `MAX(streak_months)` isolates the single longest streak achieved by each user, fully satisfying the retention team's request.