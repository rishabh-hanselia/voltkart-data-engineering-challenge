# Voltkart Advanced SQL Challenge (Session 1)

Welcome to my submission for the **Voltkart Challenge**, the first advanced SQL assignment in the **Codebasics Live Data Engineering Bootcamp**. 

This repository contains production-grade T-SQL solutions designed to move an online electronics retailer, **Voltkart**, away from fragile nightly full reloads and toward high-performance, change-driven data pipelines.

---

## 📌 Project Overview & Objectives

As Voltkart has scaled to millions of orders across India, its data infrastructure has faced severe operational bottlenecks. This project implements analytical reporting and robust data pipeline engineering using **T-SQL on SQL Server (SSMS)** to achieve two primary corporate goals:

1. **Strategic Business Analytics:** Solving real-world data requests covering running revenue trends, deep-tree recursive product category rollups, organizational chart performance aggregation, and customer retention streaks.
2. **Incremental Data Engineering (CDC):** Designing resilient, change-data-capture (CDC) pipelines utilizing `MERGE` statements to handle daily incremental batches efficiently rather than relying on full daily table drops and rebuilds.

---

## 🛠️ Data Infrastructure & Schema

The solutions inside this repository query a relational schema modeled after a scalable e-commerce infrastructure, including:
* **Facts:** `fact_orders`, `fact_order_items`
* **Dimensions (including Recursive Structures):** `dim_customer`, `dim_product`, `dim_category` (recursive category tree), and `dim_employee` (recursive corporate org chart).
* **Staging & Change Feeds:** `stg_orders_incr` (incremental orders batch) and `cdc_product_changes` (source change feed).

---

## 🚀 Engineering Principles Applied

Across these scripts, I focus on:
* **Defensive Data Architecture:** Writing structured queries (such as explicit CTE isolation paired with strategic `LEFT JOIN`s) to safeguard reporting data against upstream source pipeline inconsistencies or missing metadata.
* **Optimization & SARGability:** Rewriting non-SARGable logic (like avoiding functions on index columns), utilizing covering indexes, and eliminating costly correlated subqueries to minimize logical reads.
* **Clean Code & Readability:** Favoring modular Common Table Expressions (CTEs) over deeply nested subqueries, consistent SQL formatting, and thorough inline documentation.

---

## 📂 Repository Layout

* `/solutions` - Individual `.sql` scripts mapping to the 11 assignment questions.
* `/performance_tuning` - (For Q10) Execution plans and `SET STATISTICS IO` output captures tracking performance before and after query optimization.

---

## 📝 Detailed Solutions & Walkthroughs

### Question 1: Top 20 Completed Orders by Value

#### Business Context & Objective
The commercial team required a quick look at Voltkart's biggest transactions, pulling the top 20 completed orders alongside customer and sales representative details.

#### My Engineering Approach & Design Decisions
While the baseline hint suggests using standard `INNER JOIN`s across the schema, I deliberately chose a more robust and defensive engineering pattern using a **Common Table Expression (CTE)** and **`LEFT JOIN`s**:

1. **Explicit Predicate Isolation via CTE:** 
   The core requirement dictates that only orders with an `order_status = 'Completed'` should be considered. Instead of relying blindly on the SQL Server Query Optimizer to handle predicate pushdown, I isolated the business filtering logic into a CTE named `FilteredCompletedOrders`. This ensures that we explicitly prune out all Cancelled or Returned orders *before* any dimension matching occurs.

2. **Defensive Data Integrity using `LEFT JOIN`:** 
   In production environments, data pipelines can suffer from structural inconsistencies, such as orphaned foreign keys or deleted dimension records. Using an `INNER JOIN` poses a risk: if a high-value order lacks a corresponding record in `dim_customer` or `dim_employee`, that multi-million rupee transaction would completely vanish from the commercial report. 
   
   By pairing the CTE with a `LEFT JOIN`, I protected the integrity of the fact table rows. If a data inconsistency exists, the query will still accurately surface the transaction's revenue and ID, outputting a `NULL` for the missing dimension detail rather than dropping critical financial data entirely.

#### T-SQL Solution

```sql
-- Isolate and filter the driving fact data first to explicitly minimize downstream join volume
WITH FilteredCompletedOrders AS (
    SELECT 
        order_id, 
        order_date, 
        customer_id, 
        sales_rep_id, 
        order_total
    FROM dbo.fact_orders
    WHERE order_status = 'Completed'
)
SELECT TOP 20 
    co.order_id, 
    co.order_date, 
    c.customer_name, 
    e.employee_name AS sales_rep_name, 
    co.order_total 
FROM FilteredCompletedOrders co
LEFT JOIN dbo.dim_customer c 
    ON co.customer_id = c.customer_id 
LEFT JOIN dbo.dim_employee e 
    ON co.sales_rep_id = e.employee_id 
ORDER BY co.order_total DESC;
