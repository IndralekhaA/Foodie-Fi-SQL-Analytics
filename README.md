# 📊 Foodie-Fi Subscription Analytics Project

Welcome to the **Foodie-Fi** subscription analytics project! This end-to-end data analysis case study simulates real-world subscription business operations using SQL and data visualization tools like Tableau, Power BI, or Python.

---

## 🚀 Project Overview

Foodie-Fi is a fictional subscription-based video service that offers multiple plans (Basic, Pro, Annual, etc.). This project focuses on analyzing customer lifecycle, revenue trends, churn, upgrades, and overall product strategy using SQL and dashboard tools.

> This repository contains SQL scripts, data models, exploratory analysis, business KPIs, and placeholders for dashboards – forming a complete data analytics pipeline.

---

## 🗂️ Repository Structure
```
foodie-fi-sql-analytics/
|-- sql_scripts/
|   |-- schema_setup.sql
|   |-- generate_payments_procedure.sql
|   |-- analysis_queries.sql
|
|-- docs/
|   |-- project_report.md
|   |-- ERD.png
|
|-- dashboard/       # (To be Added Tableau / Power BI / Python files)
|   |-- README.md
|   |-- foodiefi_dashboard.pbix
|   |-- foodiefi_dashboard.twb
|   |-- viz_python_notebook.ipynb
|
|-- README.md

```

---

## 📌 Objectives

- Generate payments data from subscription records using SQL.
- Track revenue by plan and time period.
- Analyze growth, churn, upgrades, and downgrades.
- Build visual dashboards to communicate business insights.
- Simulate real-world product strategy and retention optimization.

---

## 🛠️ Tools & Technologies

- **SQL (MySQL)** – core logic and data modeling
- **Python / Tableau / Power BI (Free versions)** – dashboarding and data viz
- **Git & GitHub** – version control and sharing
- **Stored Procedures** – for monthly billing simulation

---

## 🧠 Key Insights Extracted

- Revenue breakdown by plan and time
- Churned users and time-to-churn analysis
- Monthly growth rate of new paying customers
- Upgrade/Downgrade behavior over time
- Customer journey patterns

---

## 🔍 Sample SQL Queries Answered

- How many users upgraded/downgraded?
- What is the total revenue generated per plan?
- What’s the monthly growth rate in 2020?
- Which customers churned after how many days?
- Which plan has the highest lifetime value?

> See `/sql_scripts/` folder for all queries and logic.

---

## 📊 Dashboards (Coming Soon)

- Power BI and Tableau dashboards are under development and will be added in the `/dashboards/` folder.
- Visuals will include:
  - Revenue trends
  - Monthly customer growth
  - Churn and retention curves
  - Upgrade/downgrade flow diagrams

---

## ✅ How to Use

1. Clone the repo
2. Create the schema in MySQL using `schema.sql`
3. Use `generate_payments_procedure.sql` to populate the payments table
4. Run analysis queries from the `/sql/` folder
5. Load data into Tableau/Power BI/Python for visualization

---

## 📄 Documentation

- Full project report: [`project_report.md`](./docs/project_report.md)
- Includes data flow, analysis logic, and strategic business insights

---

## 📧 Contact

For queries, collaborations, or feedback:
**Indra A**  

---

## ⭐ Future Improvements

- Predictive churn modeling using Python
- Real-time retention dashboard (if data were streaming)
- A/B test simulation for pricing strategy

---

_This project demonstrates the practical application of SQL analytics and business intelligence to help stakeholders make informed decisions based on customer behavior and subscription economics._
