# ☕ Coffee Sales Analytics | SQL Server + Power BI

An end-to-end Business Intelligence project that transforms raw coffee sales data into actionable business insights using SQL Server, a Medallion Data Warehouse Architecture (Bronze → Silver → Gold), and interactive Power BI dashboards.

---

## 📌 Project Overview

This project demonstrates a complete analytics workflow, from raw transactional data to executive dashboards.

The goal was to simulate a real-world Business Intelligence solution by:

- Building a SQL Server Data Warehouse
- Cleaning and validating raw data
- Creating analytical data models
- Writing business-focused SQL analysis
- Developing reusable reporting views
- Building interactive Power BI dashboards

---

## 🏗️ Architecture

```
                Raw CSV Files
                      │
                      ▼
               Bronze Layer
          (Raw Data Ingestion)
                      │
                      ▼
               Silver Layer
      (Cleaning & Data Quality)
                      │
                      ▼
                Gold Layer
      (Business Ready Data Model)
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
   Customer Report View     Product Report View
          │                       │
          └───────────┬───────────┘
                      ▼
               Power BI Dashboard
```

---

## 🛠️ Tech Stack

- SQL Server
- T-SQL
- Power BI
- DAX
- Data Modeling
- Data Warehousing
- ETL
- Git
- GitHub

---

# 📂 Project Structure

```
sql-coffee-sales/

├── analysis/
│   ├── 01_database_exploration.sql
│   ├── 02_measures.sql
│   ├── 03_time_analysis.sql
│   ├── 04_cumulative_analysis.sql
│   ├── 05_change_over_time.sql
│   ├── 06_performance_analysis.sql
│   ├── 07_data_segmentation.sql
│   ├── 08_part_to_whole_analysis.sql
│   ├── 09_customer_report_view.sql
│   └── 10_product_report_view.sql
│
├── datasets/
│
├── scripts/
│
├── powerbi/
│   ├── executive_dashboard.png
│   ├── customer_analysis.png
│   ├── product_analysis.png
│
└── README.md
```

---

# 📊 Dashboards

## Executive Dashboard

Provides a high-level overview of business performance.

### KPIs

- Total Sales
- Total Profit
- Profit Margin %
- Total Orders
- Total Customers
- Average Order Value
- Average Quantity per Order

### Visualizations

- Monthly Sales Trend
- Sales by Country
- Sales by Roast Type
- Top Products by Sales
- Sales by Customer Segment

---

## Customer Analysis

Designed to understand customer purchasing behavior.

### KPIs

- Total Customers
- Average Customer Spending
- Average Orders per Customer
- Loyalty Customer %
- High Value Customers
- Repeat Customer Rate

### Visualizations

- Customer Spending Segments
- Loyalty vs Non-Loyalty Customers
- Spending Quartiles
- Top Customers by Sales

---

## Product Analysis

Focused on product performance and profitability.

### KPIs

- Total Products
- Average Product Sales
- Average Product Profit
- Average Units Sold
- Best Selling Product
- Highest Profit Product

### Visualizations

- Sales by Coffee Type
- Sales by Size Category
- Top Products by Profit
- Sales vs Profit Scatter Plot

---

# 🔍 Business Analysis

Throughout the project, SQL was used to answer business questions such as:

- Which coffee type generates the most revenue?
- Which products are the most profitable?
- Which customer segments generate the highest sales?
- How are customers distributed by spending?
- What percentage of sales comes from loyalty customers?
- Which products contribute the most profit?
- Which countries generate the highest revenue?

---

# 🧹 Data Warehouse

The project follows the Medallion Architecture.

### Bronze Layer

- Raw data ingestion
- No transformations

### Silver Layer

- Data cleaning
- Duplicate removal
- Data validation
- Standardization
- Null handling

### Gold Layer

Business-ready dimensional model including:

- FactOrders
- DimCustomers
- DimProducts

---

# 📈 Power BI Features

- Interactive filters
- Dynamic KPIs
- DAX Measures
- Star Schema
- Drill-down Analysis
- Cross Filtering
- Executive Reporting

---

# 💡 Skills Demonstrated

- SQL Querying
- Common Table Expressions (CTEs)
- Window Functions
- Aggregations
- CASE Expressions
- Data Cleaning
- ETL Design
- Data Modeling
- Star Schema
- Business Intelligence
- Dashboard Design
- DAX Measures
- Analytical Thinking

---

## Executive Dashboard

![Executive Dashboard](powerbi/executive_dashboard.png)

---

## Customer Analysis

![Customer Analysis](powerbi/customer_analysis.png)

---

## Product Analysis

![Product Analysis](powerbi/product_analysis.png)

---

## Dashboard Demo

![Dashboard Demo](powerbi/powerbi_dashboard_demo01.gif)

# 🚀 Key Takeaways

This project simulates the workflow of a Business Intelligence Analyst by combining data engineering, SQL analytics, and dashboard development into a complete reporting solution.

The final deliverable enables business users to explore sales performance, customer behavior, and product profitability through interactive Power BI dashboards.

---

## 👤 Author

Kevin Garcia

GitHub:
https://github.com/datasci-kevin

---
