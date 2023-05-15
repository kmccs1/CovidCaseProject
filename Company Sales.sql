/*  Sales Dataset Portfolio Project

Skills Used: Alter, Insert, Update, Rename, Aggregate Functions, CTEs, Rank, Format, DateDiff 

Part 1 - Populating, Altering, and Cleaning Tables

*/

SELECT * 
FROM portfolioproject..salesdata
ORDER BY 'row id'


INSERT INTO portfolioproject..salesdata 
VALUES ('9995','US-2018-168754', '2018-08-09', '2018-08-10', 'First Class', 'ES-14080', 'Erin Smith', 
'Corporate', 'United States', 'Tucson', 'Arizona', '85705', 'West', 'TEC-OXP-302', 'Office Supplies', 
'Supplies', 'Ballpoint Pen (100)', '24.99', '2', '0', '49.98')

--Removing Spaces in Column Names
sp_rename 'salesdata.Row ID', 'RowID'
sp_rename 'salesdata.Order ID', 'OrderID'
sp_rename 'salesdata.Order Date', 'OrderDate'
sp_rename 'salesdata.Ship Date', 'ShipDate' 
sp_rename 'salesdata.Ship Mode', 'ShipMode'
sp_rename 'salesdata.Product ID', 'ProductID'
sp_rename 'salesdata.Product Name', 'ProductName'
sp_rename 'salesdata.Customer ID', 'CustomerID'
sp_rename 'salesdata.Customer Name', 'CustomerName'
sp_rename 'salesdata.Sub-Category', 'SubCategory'


SELECT * 
FROM portfolioproject..salesdata
ORDER BY RowID


--Removing Timestamps

ALTER TABLE portfolioproject..salesdata
ALTER COLUMN OrderDate date

ALTER TABLE portfolioproject..salesdata
ALTER COLUMN ShipDate date


-- Updating Records - Fixing Customer Name

UPDATE PortfolioProject..salesdata
SET CustomerName = 'Claire Guten'
WHERE CustomerName = 'Claire Gute'




/* 

Part 2 - Data Analysis 

*/ 


SELECT *
FROM portfolioproject..salesdata


--Find All the Furniture Orders in Florida from 2016

SELECT * 
FROM PortfolioProject..salesdata
WHERE state like 'Florida'
AND Category like 'Furniture'
AND orderdate between '2016-01-01' and '2016-12-31'


-- Find Total Purchases from Each Category in California; Order from Highest to Lowest

SELECT Category, SUM(Profit) as total
FROM PortfolioProject..salesdata
WHERE state = 'California'
GROUP BY category
ORDER by total desc


-- Find the Biggest Customer from Each State 

WITH CTE AS (
	SELECT customerID, state, SUM(Profit) Total
	FROM portfolioproject..salesdata
	GROUP BY customerID, state
	)
SELECT * FROM CTE
WHERE Total IN (SELECT MAX(total) FROM CTE GROUP BY State)


-- Find which state has the most customers

WITH CTE AS (
	SELECT state, 
	COUNT(distinct customerID) as custCount
	FROM portfolioproject..salesdata
	GROUP by state
	)
SELECT * FROM CTE
WHERE custcount IN (SELECT MAX(Custcount) FROM CTE)


--Find largest 10 customers by overall spend and format as USD

SELECT dense_rank() OVER (order BY customerspend DESC) as CustomerRankbySpend, 
	customerID, 
	format(customerspend, 'c')
FROM (
	SELECT customerID, sum(profit) as customerspend
	FROM portfolioproject..salesdata
	GROUP BY customerID) sq
Order by customerrankbyspend
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY


-- RFM (Recency, Frequency, Monetary) Analysis of Customer Base

SELECT customername, 
	MAX(OrderDate) LastOrderDate,
	DATEDIFF(DD, MAX(orderDate), (SELECT MAX(orderdate) FROM portfolioproject..salesdata)) Recency,
	COUNT(orderid) Frequency,
	Format(SUM(profit), 'c') TotalSpend,
	Format(AVG(profit), 'c') AvgSpend
FROM portfolioproject..salesdata
GROUP by customername
Order By customername










