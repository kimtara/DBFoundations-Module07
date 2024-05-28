--*************************************************************************--
-- Title: Assignment07
-- Author: KHarms
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,KHarms,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_KHarms')
	 Begin 
	  Alter Database [Assignment07DB_KHarms] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_KHarms;
	 End
	Create Database Assignment07DB_KHarms;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_KHarms;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --
/*
--determine Select statment
SELECT ProductName
	,UnitPrice
FROM vProducts
go
--format price as US dollars
SELECT ProductName
	,Format(UnitPrice,'c','en-US') AS UnitPrice
FROM vProducts
ORDER BY ProductName;
go
*/
--create function
go
CREATE FUNCTION dbo.fProductsUSDollars()
RETURNS TABLE
AS
RETURN(
	SELECT TOP 10000 ProductName
		,Format(UnitPrice,'c','en-US') AS UnitPrice
	FROM vProducts
	ORDER BY ProductName);
go
--get results 
SELECT * FROM dbo.fProductsUSDollars()
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --
/*
--determine Select statment
SELECT CategoryName
	,ProductName
	,UnitPrice
FROM vCategories AS c
INNER JOIN vProducts AS p
ON c.CategoryID = p.CategoryID;
go
--format price as US dollars
SELECT CategoryName
	,ProductName
	,Format(UnitPrice,'c','en-US') AS UnitPrice
FROM vCategories AS c
INNER JOIN vProducts AS p
ON c.CategoryID = p.CategoryID;
go
--order by category and product
SELECT CategoryName
	,ProductName
	,Format(UnitPrice,'c','en-US') AS UnitPrice
FROM vCategories AS c
INNER JOIN vProducts AS p
ON c.CategoryID = p.CategoryID
ORDER BY CategoryName, ProductName;
go
*/
--create function
go
CREATE FUNCTION dbo.fCategoryProductsUSD()
RETURNS TABLE
AS
RETURN(
	SELECT TOP 1000 CategoryName
		,ProductName
		,Format(UnitPrice,'c','en-US') AS UnitPrice
	FROM vCategories AS c
	INNER JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
	ORDER BY CategoryName, ProductName);
go
--get results 
SELECT * FROM dbo.fCategoryProductsUSD();
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/*
--define select statement
SELECT ProductName
	,InventoryDate
	,[Count]
FROM vProducts AS p
INNER JOIN vInventories AS i
ON i.ProductID = p.ProductID;
go
--format date like 'January, 2017'
SELECT DATENAME(month, InventoryDate) AS DateStringMonth
	,DATENAME(year, InventoryDate) AS DateStringYear
FROM vInventories;
go
SELECT DATENAME(month, InventoryDate)+', '+DATENAME(year, InventoryDate) AS InventoryDate
FROM vInventories;
go
--add formatted date to select statement nd order by product and date
SELECT ProductName
	,DATENAME(month, InventoryDate)+', '+DATENAME(year, InventoryDate) AS InventoryDate
	,[Count] AS InventoryCount
FROM vProducts AS p
INNER JOIN vInventories AS i
ON i.ProductID = p.ProductID
ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);
go
*/
--create function
go
CREATE FUNCTION dbo.fProductsCountDates()
RETURNS TABLE
AS
RETURN(
	SELECT TOP 10000 
		ProductName
		,DATENAME(month, InventoryDate)+', '+DATENAME(year, InventoryDate) AS InventoryDate
		,[Count] AS InventoryCount
	FROM vProducts AS p
	INNER JOIN vInventories AS i
	ON i.ProductID = p.ProductID
	ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate));
go
--select reults
SELECT * FROM dbo.fProductsCountDates()
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/*
--define select statement
SELECT ProductName
	,DATENAME(month, InventoryDate)+', '+DATENAME(year, InventoryDate) AS InventoryDate
	,[Count] AS InventoryCount
FROM vProducts AS p
INNER JOIN vInventories AS i
ON i.ProductID = p.ProductID
ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);
go
*/
--create view
go
CREATE VIEW vProductInventories
AS
	SELECT TOP 1000 ProductName
		,DATENAME(month, InventoryDate)+', '+DATENAME(year, InventoryDate) AS InventoryDate
		,[Count] AS InventoryCount
	FROM vProducts AS p
	INNER JOIN vInventories AS i
	ON i.ProductID = p.ProductID
	ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);
go
-- Check that it works: 
SELECT * FROM vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Category and Date.

-- <Put Your Code Here> --
/*
--define select statement, joining category, products, and inventory base views
SELECT CategoryName
	,InventoryDate
	,[Count]
FROM vCategories AS c
INNER JOIN vProducts AS p
ON c.CategoryID = p.CategoryID
INNER JOIN vInventories AS i
ON p.CategoryID = i.ProductID;
go
--format date like 'January, 2017'
SELECT CategoryName
	,DATENAME(month, InventoryDate)+', '+DATENAME(year, InventoryDate) AS InventoryDate
	,[Count]
FROM vCategories AS c
INNER JOIN vProducts AS p
ON c.CategoryID = p.CategoryID
INNER JOIN vInventories AS i
ON p.CategoryID = i.ProductID;
go
--total inventory count by category and order by category and date
SELECT CategoryName
	,DATENAME(month, InventoryDate)+', '+DATENAME(year, InventoryDate) AS InventoryDate
	,Sum([Count]) AS InventoryCountByCategory
FROM vCategories AS c
INNER JOIN vProducts AS p
ON c.CategoryID = p.CategoryID
INNER JOIN vInventories AS i
ON p.CategoryID = i.ProductID
GROUP BY CategoryName, InventoryDate
ORDER BY CategoryName, YEAR(InventoryDate), MONTH(InventoryDate);
go
*/
--create view
go
CREATE VIEW vCategoryInventories
AS(
	SELECT TOP 1000 CategoryName
		,DATENAME(month, InventoryDate)+', '+DATENAME(year, InventoryDate) AS InventoryDate
		,Sum([Count]) AS InventoryCountByCategory
	FROM vCategories AS c
	INNER JOIN vProducts AS p
	ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories AS i
	ON p.CategoryID = i.ProductID
	GROUP BY CategoryName, InventoryDate
	ORDER BY CategoryName, YEAR(InventoryDate), MONTH(InventoryDate));
go
-- Check that it works: 
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
/*
--show view
SELECT * FROM vProductInventories;
--add in previous month counts partitioned by ProductName
SELECT ProductName
	,InventoryDate
	,InventoryCount
	,LAG(InventoryCount,1) OVER (PARTITION BY ProductName ORDER BY ProductName )
FROM vProductInventories;
--set Null counts to zero
SELECT ProductName
	,InventoryDate
	,InventoryCount
	,ISNULL(LAG(InventoryCount,1) OVER (PARTITION BY ProductName ORDER BY ProductName ),0)
FROM vProductInventories;
--order by product and date
SELECT ProductName
	,InventoryDate
	,InventoryCount
	,ISNULL(LAG(InventoryCount,1) OVER (PARTITION BY ProductName ORDER BY ProductName ),0) AS PreviousMonthCount
FROM vProductInventories
ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);
*/
--create view
go
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
AS
	SELECT TOP 10000 ProductName
		,InventoryDate
		,InventoryCount
		,ISNULL(LAG(InventoryCount,1) OVER (PARTITION BY ProductName ORDER BY ProductName ),0) AS PreviousMonthCount
	FROM vProductInventories
	ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);
go
-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
/*
--show view
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
--define select statement
SELECT 
	ProductName
	,InventoryDate
	,InventoryCount
	,PreviousMonthCount
FROM vProductInventoriesWithPreviousMonthCounts;
--add in KPI and ensure order by product and date
SELECT 
	ProductName
	,InventoryDate
	,InventoryCount
	,PreviousMonthCount
	,[CountVsPreviousCountKPI] = CASE  
									WHEN InventoryCount>PreviousMonthCount THEN 1
									WHEN InventoryCount=PreviousMonthCount THEN 0
									WHEN InventoryCount<PreviousMonthCount THEN -1
									ELSE 'No info yet'
									END
FROM vProductInventoriesWithPreviousMonthCounts
ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);
*/
--create view
go
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS(
	SELECT TOP 10000
		ProductName
		,InventoryDate
		,InventoryCount
		,PreviousMonthCount
		,[CountVsPreviousCountKPI] = CASE  
										WHEN InventoryCount>PreviousMonthCount THEN 1
										WHEN InventoryCount=PreviousMonthCount THEN 0
										WHEN InventoryCount<PreviousMonthCount THEN -1
										ELSE 'No info yet'
										END
	FROM vProductInventoriesWithPreviousMonthCounts
	ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate));
go
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
/*
--use same code as for question to set up select statement
go
	SELECT TOP 10000
		ProductName
		,InventoryDate
		,InventoryCount
		,PreviousMonthCount
		,CountVsPreviousCountKPI
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
	ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);
go
--add in where clauses to make three statements based on KPI of -1, 0, 1
SELECT TOP 10000
		ProductName
		,InventoryDate
		,InventoryCount
		,PreviousMonthCount
		,CountVsPreviousCountKPI
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
	WHERE CountVsPreviousCountKPI=1
	ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);

SELECT TOP 10000
	ProductName
	,InventoryDate
	,InventoryCount
	,PreviousMonthCount
	,CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
WHERE CountVsPreviousCountKPI=-1
ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);

SELECT TOP 10000
	ProductName
	,InventoryDate
	,InventoryCount
	,PreviousMonthCount
	,CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
WHERE CountVsPreviousCountKPI=0
ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate);
*/
--create UDF
go
CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
RETURNS @results TABLE (
		ProductName sql_variant
		,InventoryDate sql_variant
		,InventoryCount sql_variant
		,PreviousMonthCount sql_variant
		,CountVsPreviousCountKPI sql_variant)
AS
BEGIN
	IF @KPI = 0
		INSERT INTO @results
			SELECT TOP 10000
				ProductName
				,InventoryDate
				,InventoryCount
				,PreviousMonthCount
				,CountVsPreviousCountKPI
			FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
			WHERE CountVsPreviousCountKPI=0
			ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate)
	ELSE IF @KPI = 1
		INSERT INTO @results
			SELECT TOP 10000
				ProductName
				,InventoryDate
				,InventoryCount
				,PreviousMonthCount
				,CountVsPreviousCountKPI
			FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
			WHERE CountVsPreviousCountKPI=1
			ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate)
	ELSE IF @KPI = -1
		INSERT INTO @results
			SELECT TOP 10000
				ProductName
				,InventoryDate
				,InventoryCount
				,PreviousMonthCount
				,CountVsPreviousCountKPI
			FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
			WHERE CountVsPreviousCountKPI=-1
			ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate)
RETURN
END;
go

--Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/