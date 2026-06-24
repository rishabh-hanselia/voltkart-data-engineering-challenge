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

## 📝 Interactive Assignment Directory

### 📅 Week 1: Advanced SQL for Modern Data Engineering

Click on any question to view its dedicated architectural write-up or to jump directly into its production T-SQL script.

| # | Challenge Objective | Technical Write-up | Production T-SQL Script |
|---|:---|:---:|:---:|
| **01** | Top 20 Completed Orders by Value | [📄 View Architecture](./documentation/W1_Q1_Writeup.md) | [💻 View Script](./solutions/W1_Q1.sql) |
| **02** | Inactive Customer Identification | [📄 View Architecture](./documentation/W1_Q2_Writeup.md) | [💻 View Script](./solutions/W1_Q2.sql) |
| **03** | Top 3 Products Per Category | [📄 View Architecture](./documentation/W1_Q3_Writeup.md) | [💻 View Script](./solutions/W1_Q3.sql) |
| **04** | MoM Revenue Trend & Momentum | [📄 View Architecture](./documentation/W1_Q4_Writeup.md) | [💻 View Script](./solutions/W1_Q4.sql) |
