# Voltkart Advanced SQL Challenge (Session 1)

Welcome to my submission for the **Voltkart Challenge**, the first advanced SQL assignment in the **Codebasics Live Data Engineering Bootcamp**[cite: 1]. 

This repository contains production-grade T-SQL solutions designed to move an online electronics retailer, **Voltkart**, away from fragile nightly full reloads and toward high-performance, change-driven data pipelines[cite: 1, 2].

---

## 📌 Project Overview & Objectives

As Voltkart has scaled to millions of orders across India, its data infrastructure has faced severe operational bottlenecks[cite: 2]. This project implements analytical reporting and robust data pipeline engineering using **T-SQL on SQL Server (SSMS)** to achieve two primary corporate goals[cite: 2, 3]:

1. **Strategic Business Analytics:** Solving real-world data requests covering running revenue trends, deep-tree recursive product category rollups, organizational chart performance aggregation, and customer retention streaks[cite: 2, 3].
2. **Incremental Data Engineering (CDC):** Designing resilient, change-data-capture (CDC) pipelines utilizing `MERGE` statements to handle daily incremental batches efficiently rather than relying on full daily table drops and rebuilds[cite: 2, 3].

---

## 🛠️ Data Infrastructure & Schema

The solutions inside this repository query a relational schema modeled after a scalable e-commerce infrastructure[cite: 2], including:
* **Facts:** `fact_orders`, `fact_order_items`[cite: 2, 5]
* **Dimensions (including Recursive Structures):** `dim_customer`, `dim_product`, `dim_category` (recursive category tree), and `dim_employee` (recursive corporate org chart)[cite: 2, 5].
* **Staging & Change Feeds:** `stg_orders_incr` (incremental orders batch) and `cdc_product_changes` (source change feed)[cite: 2, 5].

---

## 🚀 Engineering Principles Applied

Across these scripts, I focus on:
* **Defensive Data Architecture:** Writing structured queries (such as explicit CTE isolation paired with strategic `LEFT JOIN`s) to safeguard reporting data against upstream source pipeline inconsistencies or missing metadata.
* **Optimization & SARGability:** Rewriting non-SARGable logic (like avoiding functions on index columns), utilizing covering indexes, and eliminating costly correlated subqueries to minimize logical reads[cite: 1, 3].
* **Clean Code & Readability:** Favoring modular Common Table Expressions (CTEs) over deeply nested subqueries, consistent SQL formatting, and thorough inline documentation[cite: 1].

---

## 📂 Repository Layout

* `/solutions` - Individual `.sql` scripts mapping to the 11 assignment questions[cite: 1, 3].
* `/performance_tuning` - (For Q10) Execution plans and `SET STATISTICS IO` output captures tracking performance before and after query optimization[cite: 1, 3].

---

## 📝 Detailed Solutions & Walkthroughs

### Question 1: Top 20 Completed Orders by Value
*(Your Question 1 write-up from earlier goes right here!)*
