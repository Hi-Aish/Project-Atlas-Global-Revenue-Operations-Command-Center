# Project Atlas Global Revenue & Operations Command Center

<img width="1326" height="750" alt="image" src="https://github.com/user-attachments/assets/264408e4-84e4-494e-8b9c-a1bdcfb1d4e2" />

An enterprise-grade, interactive Power BI dashboard designed to provide stakeholders with an instant 10-second executive summary of revenue health, product performance, and customer segmentation. Built following modern SaaS UI/UX design principles to support data-driven decision-making.

---

## 📌 Project Overview
In modern business environments, raw data is abundant, but actionable insights are rare. **Project Atlas Global Revenue & Operations Command Center** bridges that gap by transforming raw transactional records into a cohesive, interactive reporting tool. 

The dashboard answers four critical business questions:
1. **How much revenue did we generate?** (High-level KPIs)
2. **When do sales peak and dip?** (Year-over-Year Trend Analysis)
3. **What are our top and bottom product drivers?** (Ranked Performance Bars)
4. **Who are our core buyers?** (Customer Segmentation)

---

## 📂 Data Source & Schema
*   **Data Source:** [Kaggle - Global Superstore 2016 Dataset](https://www.kaggle.com/datasets/tahir1413/global-superstore-2016)
*   **Raw File:** `orders.csv` (extracted from the Global Superstore dataset and imported into MySQL for downstream data cleansing).
*   **Data Architecture:** Modeled using clean SQL Views to structure a **Star Schema** for optimal reporting and query performance.

---

## 🛠️ SQL Data Cleaning & Preparation
The raw CSV was imported into MySQL, where the data was cleaned, structured, and organized into a star schema using relational Views. This included stripping currency formatting, casting data types, and implementing window functions.

**[Click here to view the full SQL cleaning script](sql/data_cleaning.sql)**

---

## 🗄️ Data Modeling & Relational Architecture
Project Atlas utilizes a robust **Star Schema** to ensure optimal query performance, rapid filter propagation, and seamless cross-visualization behavior.

### 1. Schema Structure
*   **Fact Table (`Fact_Sales`):** The transactional grain of the business. Each row represents an individual order line item containing foreign keys (`CustomerID`, `ProductID`), core numerical metrics (`SalesAmount`, `ProfitAmount`, `Quantity`, `DiscountAmount`), and calculated performance fields.
*   **Dimension Tables (`Dim_Customer`, `Dim_Product`, `Dim_Date`):** 
    *   `Dim_Customer`: Houses unique customer records and segmentation data (Consumer, Corporate, Home Office).
    *   `Dim_Product`: Houses unique product records, categories, and sub-categories.
    *   `Dim_Date`: A dedicated continuous calendar table ensuring all time-intelligence calculations (`SAMEPERIODLASTYEAR`, running totals) function without gaps.

### 2. Relationship Cardinality & Filter Direction
*   **`Dim_Date` (1) $\to$ `Fact_Sales` (*):** Connected via `Date` to `OrderDate` with a 1-to-Many cardinality and a Single (one-way) filter direction.
*   **`Dim_Customer` (1) $\to$ `Fact_Sales` (*):** Connected via `CustomerID` with a 1-to-Many cardinality and Single filter direction.
*   **`Dim_Product` (1) $\to$ `Fact_Sales` (*):** Connected via `ProductID` with a 1-to-Many cardinality and Single filter direction.

---

## 💻 Core DAX Formulas & Time Intelligence
Custom DAX measures and calculated columns were implemented to handle calculations, proper chronological sorting, and time intelligence inside Power BI:

### 1. Calendar Dimension & Chronological Sorting
*   **Month (Text):** `Month = FORMAT(Dim_Date[Date], "MMMM")`
*   **Month Number (Index):** `Month Number = MONTH(Dim_Date[Date])` *(Applied via "Sort by column")*
*   **Year:** `Year = YEAR(Dim_Date[Date])`
*   **Quarter:** `Quarter = CONCATENATE("Q", QUARTER(Dim_Date[Date]))`

### 2. Core Business Measures
*   **Total Sales:** `Total Sales = SUM(Fact_Sales[SalesAmount])`
*   **Previous Year Sales:** `Previous Year Sales = CALCULATE([Total Sales], SAMEPERIODLASTYEAR(Dim_Date[Date]))`
*   **YoY Growth %:** `YoY Growth % = DIVIDE([Total Sales] - [Previous Year Sales], [Previous Year Sales], 0)`

---

## 📊 Dashboard Architecture & Visual Readings

### 1. Executive Summary Cards (Top Banner)
*   **Business Reading:** Provides an instant baseline of overall financial health and annual trajectory.

### 2. Revenue Performance vs. Previous Year (Line Chart)
*   **Business Reading:** Exposes seasonality, highlights growth gaps between fiscal years, and flags structural anomalies.

### 3. Customer Segmentation (Donut Chart)
*   **Business Reading:** Identifies revenue concentration by buyer type to align marketing and sales strategies.

### 4. Top 5 & Bottom 5 Products (Bar Charts)
*   **Business Reading:** Identifies top revenue drivers and margin-diluting dead weight using color psychology.

---

## 🚀 Key Achievements & Business Impact
*   **Reduced Decision Latency:** Condensed thousands of rows of sales data into an interactive, 10-second executive overview.
*   **Enhanced Interactivity:** Integrated synced dropdown slicers for Year, Month, and Quarter for dynamic data exploration.
*   **Portfolio Ready:** Demonstrated full-stack competency in SQL data transformation, relational database architecture, DAX modeling, and professional UI/UX design.
