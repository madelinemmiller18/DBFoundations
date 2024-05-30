--*************************************************************************--
-- Title: Assignment07
-- Author: MadelineMiller
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2024-05-28,MadelineMiller,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_MadelineMiller')
	 Begin 
	  Alter Database [Assignment07DB_MadelineMiller] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_MadelineMiller;
	 End
	Create Database Assignment07DB_MadelineMiller;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_MadelineMiller;

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
/* ----------------------------------------------------------------------------------------- Question 1
--Select table
SELECT * FROM vProducts p
-- Relevant columns
SELECT p.ProductName, p.UnitPrice 
FROM vProducts p
-- Use format function, set format to currency ('c') and culture to USA ('en-US')
SELECT p.ProductName, FORMAT(p.UnitPrice, 'c', 'en-US') as ProductPriceUS
FROM vProducts p
*/ 
--Add order by product name
--Final Code ----------------------------------------------------------------------------------------- Question 1 Final Code
SELECT 
	p.ProductName, 
	FORMAT(p.UnitPrice, 'c', 'en-US') as ProductPriceUS
FROM vProducts p
ORDER BY p.ProductName;

go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --
/* ----------------------------------------------------------------------------------------- Question 2
--Start with final code from question 1
SELECT p.ProductName, FORMAT(p.UnitPrice, 'c', 'en-US') as ProductPriceUS
FROM vProducts p
ORDER BY p.ProductName
--Join Categories
SELECT p.ProductName, FORMAT(p.UnitPrice, 'c', 'en-US') as ProductPriceUS
FROM vProducts p
JOIN vCategories c ON p.CategoryID = c.CategoryID
ORDER BY p.ProductName
*/
--Add CategoryName to SELECT and ORDER
--Final Code ----------------------------------------------------------------------------------------- Question 2 Final Code
SELECT 
	c.CategoryName, 
	p.ProductName, 
	FORMAT(p.UnitPrice, 'c', 'en-US') as ProductPriceUS
FROM vProducts p
	JOIN vCategories c 
	ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName;

go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/* ----------------------------------------------------------------------------------------- Question 3
--Select relevant product name, inventory date, and inventory count 
--from Products and Inventories
SELECT p.ProductName, i.InventoryDate, i.[Count]
FROM vInventories i
JOIN vProducts p ON i.ProductID = p.ProductID
--Format the date like 'January, 2017'
SELECT 
	p.ProductName, 
	DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(yy, i.InventoryDate) AS MonthYear, 
	i.[Count]
FROM vInventories i
JOIN vProducts p ON i.ProductID = p.ProductID
*/
--Order resuts by product and date
--Final Code ----------------------------------------------------------------------------------------- Question 3 Final Code

SELECT 
	p.ProductName, 
	DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(yy, i.InventoryDate) AS InventoryDate, 
	i.[Count] 
FROM vInventories i
JOIN vProducts p ON i.ProductID = p.ProductID
ORDER BY p.ProductName, CAST(i.InventoryDate AS DATE);

go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/* ----------------------------------------------------------------------------------------- Question 4
-- Start with final code from question 3
SELECT 
	p.ProductName, 
	DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(yy, i.InventoryDate) AS InventoryDate, 
	i.[Count] 
FROM vInventories i
JOIN vProducts p ON i.ProductID = p.ProductID
ORDER BY p.ProductName, CAST(i.InventoryDate AS DATE)
*/
-- Create the view
--Final Code ----------------------------------------------------------------------------------------- Question 4 Final Code
CREATE VIEW vProductInventories
AS
	SELECT TOP 1000000000
		p.ProductName, 
		DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(yy, i.InventoryDate) AS InventoryDate, 
		i.[Count] 
	FROM vInventories i
	JOIN vProducts p ON i.ProductID = p.ProductID
	ORDER BY p.ProductName, CAST(i.InventoryDate AS DATE);
go

-- Check that it works: Select * From vProductInventories;
SELECT *
FROM vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
/* ----------------------------------------------------------------------------------------- Question 5
--Select all from categories and inventories
SELECT c.*, i.*
FROM vCategories c
JOIN vProducts p ON c.CategoryID = p.ProductID
JOIN vInventories i ON p.ProductID = i.ProductID
--Select Category names, Inventory Dates, and Inventory Count
SELECT c.CategoryName, i.InventoryDate, i.[Count]
FROM vCategories c
JOIN vProducts p ON c.CategoryID = p.ProductID
JOIN vInventories i ON p.ProductID = i.ProductID
--Format date
SELECT 
    c.CategoryName, 
    DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(yy, i.InventoryDate) AS MonthYear, 
    i.[Count]
FROM vCategories c
JOIN vProducts p ON c.CategoryID = p.ProductID
JOIN vInventories i ON p.ProductID = i.ProductID
-- Add GROUP BY clause and TOTAL Inventory Count BY CATEGORY
SELECT 
    c.CategoryName, 
    DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(yy, i.InventoryDate) AS MonthYear, 
    SUM(i.[Count]) AS TotalCategoryInventory
FROM vCategories c
JOIN vProducts p ON c.CategoryID = p.ProductID
JOIN vInventories i ON p.ProductID = i.ProductID
GROUP BY c.CategoryName, i.InventoryDate
-- Order the results by the Product and Date
SELECT 
    c.CategoryName, 
    DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(yy, i.InventoryDate) AS MonthYear, 
    SUM(i.[Count]) AS TotalCategoryInventory
FROM vCategories c
JOIN vProducts p ON c.CategoryID = p.CategoryID
JOIN vInventories i ON p.ProductID = i.ProductID
GROUP BY c.CategoryName, i.InventoryDate
ORDER BY c.CategoryName i.InventoryDate
*/
-- Create view, adding TOP to allow for order
--Final Code ----------------------------------------------------------------------------------------- Question 5 Final Code
CREATE VIEW vCategoryInventories
AS
    SELECT TOP 100000000000
        c.CategoryName, 
        DATENAME(mm,i.InventoryDate) + ', ' + DATENAME(yy, i.InventoryDate) AS InventoryDate, 
        SUM(i.[Count]) AS TotalCategoryInventory
    FROM vCategories c
    JOIN vProducts p ON c.CategoryID = p.CategoryID
    JOIN vInventories i ON p.ProductID = i.ProductID
    GROUP BY c.CategoryName, i.InventoryDate
    ORDER BY c.CategoryName, CAST(i.InventoryDate AS DATE);

go
-- Check that it works: Select * From vCategoryInventories;
SELECT * FROM vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviousMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
/* ----------------------------------------------------------------------------------------- Question 6
-- Select all from vProductInventories view
SELECT * 
FROM vProductInventories vpi
--use function to add previous month count and add group by and order by statements
SELECT 
    vpi.ProductName, 
    vpi.MonthYear, 
    SUM(vpi.[Count]), 
	LAG(SUM(vpi.[Count])) Over(PARTITION BY vpi.ProductName 
	Order By vpi.ProductName, Year(vpi.MonthYear), MONTH(vpi.MonthYear)) AS PrevMonthCount
FROM vProductInventories vpi
GROUP BY vpi.ProductName, vpi.MonthYear
ORDER BY vpi.ProductName,YEAR(vpi.MonthYear), MONTH(vpi.MonthYear)
-- Use functions to set any January NULL counts to zero. 
SELECT 
    vpi.ProductName, 
    vpi.MonthYear, 
    SUM(vpi.[Count]), 
    ISNULL(
			LAG(SUM(vpi.[Count])) 
			Over(PARTITION BY vpi.ProductName Order By 
				vpi.ProductName, 
				Year(vpi.MonthYear), 
				MONTH(vpi.MonthYear)) 
			,0) AS PrevMonthCount
FROM vProductInventories vpi
GROUP BY vpi.ProductName, vpi.MonthYear
ORDER BY vpi.ProductName,YEAR(vpi.MonthYear), MONTH(vpi.MonthYear)
*/
-- Create as view, adding top statement to allow for order by
--Final Code ----------------------------------------------------------------------------------------- Question 6 Final Code
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
AS
	SELECT TOP 10000000000
		vpi.ProductName, 
		vpi.InventoryDate, 
		vpi.[Count],  
		ISNULL(
			LAG(vpi.[Count]) 
			Over(PARTITION BY vpi.ProductName Order By -- Partition by solved error of Jan values
				vpi.ProductName, 
				Year(vpi.InventoryDate), 
				MONTH(vpi.InventoryDate)) 
			,0) AS PrevMonthCount
	FROM vProductInventories vpi
	ORDER BY vpi.ProductName,CAST(vpi.InventoryDate AS DATE);
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
SELECT * FROM vProductInventoriesWithpreviousMonthCounts
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
/* ----------------------------------------------------------------------------------------- Question 7
-- Starting with vProductInventoriesWithpreviousMonthCounts
SELECT pi.ProductName, pi.MonthYear, pi.[Count], pi.PrevMonthCount
FROM vProductInventoriesWithpreviousMonthCounts pi
-- Add KPI for months with increased counts as 1, same counts as 0, and decreased counts as -1
SELECT 
	pi.ProductName, 
	pi.MonthYear, 
	pi.[Count], 
	pi.PrevMonthCount, 
	CASE 
		WHEN pi.[Count] > pi.PrevMonthCount THEN 1 
		WHEN pi.[Count] = pi.PrevMonthCount THEN 0
		WHEN pi.[Count] < pi.PrevMonthCount THEN -1 
	END AS MonthKPI 
FROM vProductInventoriesWithpreviousMonthCounts pi
-- Add order by
SELECT 
	pi.ProductName, 
	pi.MonthYear, 
	pi.[Count], 
	pi.PrevMonthCount, 
	CASE 
		WHEN pi.[Count] > pi.PrevMonthCount THEN 1 
		WHEN pi.[Count] = pi.PrevMonthCount THEN 0
		WHEN pi.[Count] < pi.PrevMonthCount THEN -1 
	END AS MonthKPI 
FROM vProductInventoriesWithpreviousMonthCounts pi
ORDER BY pi.ProductName, CAST(pi.InventoryDate AS DATE);
*/
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs with TOP to allow for order
--Final Code ----------------------------------------------------------------------------------------- Question 7 Final Code
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT TOP 1000000000000
		pi.ProductName, 
		pi.InventoryDate, 
		pi.[Count], 
		pi.PrevMonthCount, 
		CASE 
			WHEN pi.[Count] > pi.PrevMonthCount THEN 1 
			WHEN pi.[Count] = pi.PrevMonthCount THEN 0
			WHEN pi.[Count] < pi.PrevMonthCount THEN -1 
		END AS MonthKPI 
	FROM vProductInventoriesWithpreviousMonthCounts pi
	ORDER BY pi.ProductName, CAST(pi.InventoryDate AS DATE);
go
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
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
/* ----------------------------------------------------------------------------------------- Question 8
-- Select all columns from view table
SELECT 
	ProductName, 
	MonthYear, 
	MonthTotalCount, 
	PrevMonthCount, 
	MonthKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs 
-- Add where clause to be replaced with parameter name
SELECT 
	ProductName, -- include all columns from the view
	MonthYear, 
	MonthTotalCount, 
	PrevMonthCount, 
	MonthKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs 
WHERE MonthKPI = 1 -- replace this with parameter name 
-- Add order by and TOP (to allow for order by when inserted into function)
SELECT TOP 10000000000000 -- add TOP to enable order by in the function
	ProductName, -- include all columns from the view
	MonthYear, 
	[Count], 
	PrevMonthCount, 
	MonthKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs 
WHERE MonthKPI = 1 -- replace this with parameter name 
ORDER BY ProductName, MonthYear
*/
-- Insert select statement into function with parameter for KPI
--Final Code ----------------------------------------------------------------------------------------- Question 8 Final Code
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPIvalue INT)
RETURNS TABLE
AS
	RETURN(
		SELECT TOP 10000000000000
			ProductName, 
			InventoryDate,
			[Count], 
			PrevMonthCount, 
			MonthKPI
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs 
		WHERE MonthKPI = @KPIvalue
		ORDER BY ProductName, CAST(InventoryDate AS DATE)
	);
go

/* Check that it works:*/
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/