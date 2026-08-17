# Project Atlas Global Revenue & Operations Command Center

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
*   **Data Source:** Downloaded from Kaggle (Global Superstore 2016 Dataset).
*   https://www.kaggle.com/datasets/tahir1413/global-superstore-2016
*   **Raw File:** `orders.csv` (housed in the `/data` folder and imported into MySQL).
*   **Data Architecture:** Modeled using clean SQL Views to structure a **Star Schema** for optimal reporting performance.
    *   **`vw_Fact_Sales`**: Transactional view handling date casting, cleaning currency formats (`$`, `,`), and calculating metrics like running totals.
    *   **`vw_Dim_Customer`**: Distinct customer demographic profiles, locations, and market segments.
    *   **`vw_Dim_Product`**: Unique product catalogs, categories, and sub-categories.

---

## 🛠️ SQL Data Cleaning & View Creation Script
The raw CSV was imported into MySQL, and the following script was executed to clean strings, format dates, strip currency symbols, and establish the data views:

```sql
CREATE SCHEMA ProjectAtlas;
USE ProjectAtlas;

-- Step 1: Inspect raw imported data
SHOW TABLES;
DESC orders;
SELECT * FROM orders;

-- Step 2: Create Fact Table View (Handling Date casting, $ and comma removal, and window functions)
CREATE OR REPLACE VIEW vw_Fact_Sales AS
SELECT  
    `Row ID` AS RowID,
    `Order ID` AS OrderID,
    
    -- Teaching MySQL how to read M/D/YYYY formats and handle nulls/blanks
    STR_TO_DATE(`Order Date`, '%c/%e/%Y') AS OrderDate,
    
    `Customer ID` AS CustomerID,
    `Product ID` AS ProductID,
    
    -- Stripping the $ and comma, then converting to a math-ready decimal
    COALESCE(CAST(REPLACE(REPLACE(Sales, '$', ''), ',', '') AS DECIMAL(10,2)), 0) AS SalesAmount,
    COALESCE(CAST(REPLACE(REPLACE(Profit, '$', ''), ',', '') AS DECIMAL(10,2)), 0) AS ProfitAmount,
    
    COALESCE(CAST(`Discount` AS DECIMAL(5,2)), 0) AS DiscountAmount,
    CAST(`Quantity` AS UNSIGNED) AS Quantity,
    
    -- Window Function for Customer Running Total / LTV
    SUM(CAST(REPLACE(REPLACE(Sales, '$', ''), ',', '') AS DECIMAL(10,2))) OVER(
        PARTITION BY `Customer ID` 
        ORDER BY STR_TO_DATE(`Order Date`, '%c/%e/%Y')
    ) AS CustomerRunningTotal

FROM Orders
WHERE `Order ID` IS NOT NULL AND `Order ID` != '';

DESC vw_Fact_Sales;

-- Step 3: Create Customer Dimension View
CREATE VIEW vw_Dim_Customer AS
SELECT DISTINCT  
    `Customer ID` AS CustomerID, 
    `Customer Name` AS CustomerName, 
    `Segment`, 
    `City`, 
    `State`, 
    `Country`, 
    `Region`
FROM Orders
WHERE `Customer ID` IS NOT NULL AND `Customer ID` != '';

-- Step 4: Create Product Dimension View
CREATE VIEW vw_Dim_Product AS
SELECT DISTINCT  
    `Product ID` AS ProductID, 
    `Product Name` AS ProductName, 
    `Category`, 
    `Sub-Category` AS SubCategory
FROM Orders
WHERE `Product ID` IS NOT NULL AND `Product ID` != '';

-- Step 5: Verification Queries
SELECT * FROM vw_Dim_Customer;
SELECT * FROM vw_Dim_Product;
SELECT * FROM vw_Fact_Sales;
---

## ⚙️ Process & Methodology
1. **Database Ingestion & Cleaning:** Used MySQL to import raw transactional data (`orders.csv`), stripping currency text formatting (`$`, `,`), handling nulls, and parsing date strings into structured timestamp objects using `STR_TO_DATE`.
2. **Relational Modeling & Views:** Built clean database views (`vw_Fact_Sales`, `vw_Dim_Customer`, `vw_Dim_Product`) to emulate a proper star schema for efficient Power BI consumption.
3. **Time Intelligence & DAX Modeling:** Created calculated measures in Power BI to dynamically evaluate performance trends against historical baselines.
4. **UI/UX Design Overhaul:** Designed a modern, clean light-theme SaaS interface featuring container-based card layouts, drop shadows, and visual hierarchy.

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
*   **`Dim_Date` (1) $\to$ `Fact_Sales` (*):** Connected via `Date` to `OrderDate` with a 1-to-Many cardinality and a Single (one-way) filter direction flowing from the calendar dimension down to the transactions.
*   **`Dim_Customer` (1) $\to$ `Fact_Sales` (*):** Connected via `CustomerID` with a 1-to-Many cardinality and Single filter direction, ensuring customer segments filter sales accurately.
*   **`Dim_Product` (1) $\to$ `Fact_Sales` (*):** Connected via `ProductID` with a 1-to-Many cardinality and Single filter direction to drive the Top N / Bottom N product rankings cleanly.

---

## 💻 Core DAX Formulas & Time Intelligence
Custom DAX measures and calculated columns were implemented to handle calculations, proper chronological sorting, and time intelligence inside Power BI:

### 1. Calendar Dimension & Chronological Sorting Columns
*   **Extracting Month Names as Text:**
    ```dax
    Month = FORMAT(Dim_Date[Date], "MMMM")
    ```
*   **Creating a Chronological Month Number Index:**
    ```dax
    Month Number = MONTH(Dim_Date[Date])
    ```
    *(Note: Applied via **Sort by column** in Power BI on the `Month` text attribute).*

*   **Extracting Year:**
    ```dax
    Year = YEAR(Dim_Date[Date])
    ```

*   **Extracting Quarter:**
    ```dax
    Quarter = CONCATENATE("Q", QUARTER(Dim_Date[Date]))
    ```

### 2. Core Business Measures (DAX)
*   **Total Sales (Revenue):**
    ```dax
    Total Sales = SUM(Fact_Sales[SalesAmount])
    ```

*   **Previous Year Sales (YoY Time Intelligence):**
    ```dax
    Previous Year Sales = CALCULATE([Total Sales], SAMEPERIODLASTYEAR(Dim_Date[Date]))
    ```

*   **Year-over-Year (YoY) Growth Percentage:**
    ```dax
    YoY Growth % = DIVIDE([Total Sales] - [Previous Year Sales], [Previous Year Sales], 0)
    ```

---

## 📊 Dashboard Architecture & Visual Readings

### 1. Executive Summary Cards (Top Banner)
*   **Metric:** Total Sales & Year-over-Year (YoY) Growth %.
*   **Business Reading:** Gives leadership an instant baseline of overall financial health and annual trajectory before diving into granular filters.

### 2. Revenue Performance vs. Previous Year (Line Chart)
*   **Setup:** X-axis mapped to chronological months; Y-axis plots dual lines for current year revenue vs. previous year baseline.
*   **Business Reading:** Exposes business seasonality, highlights growth gaps between fiscal years, and flags structural anomalies where current performance diverges from historical benchmarks.

### 3. Customer Segmentation (Donut Chart)
*   **Setup:** Grouped by `Segment` (Consumer, Corporate, Home Office) with data labels formatted as percentages of total revenue.
*   **Business Reading:** Identifies revenue concentration by buyer type, ensuring marketing and sales teams align their acquisition strategies with high-value segments.

### 4. Top 5 & Bottom 5 Products (Bar Charts)
*   **Setup:** Filtered via Top N / Bottom N logic on product categories, utilizing visual color psychology (Vibrant Green for top performers, distinct Red for underperforming assets).
*   **Business Reading:** Eliminates the "scrollbar of death" by filtering out the noise, allowing managers to instantly identify top revenue drivers and margin-diluting dead weight.

---

## 🚀 Key Achievements & Business Impact
*   **Reduced Decision Latency:** Condensed thousands of individual rows of sales data into an interactive, 10-second executive overview.
*   **Enhanced Interactivity:** Integrated synced dropdown slicers for Year, Month, and Quarter, allowing stakeholders to dynamically slice the entire page without losing context.
*   **Portfolio Ready:** Demonstrated full-stack competency in SQL data transformation, relational database architecture, DAX modeling, and professional UI/UX presentation.
