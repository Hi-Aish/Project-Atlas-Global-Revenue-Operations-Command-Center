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