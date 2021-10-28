/* Answer following questions
1.	What is a result set?
The output of a SQL query.

2.	What is the difference between Union and Union All?
Firstable, UNION include all the duplicated rows. Then, for the UNION, the records for the first col will sorted asc. 
UNION cannot be used in recursive cte, but UNION ALL can. (Not explained yet)

3.	What are the other Set Operators SQL Server has?
INTERSECT and EXCEPT.

4.	What is the difference between Union and Join?
UNION combine the rows together vertically. JOIN combine table colunms horizentally.

5.	What is the difference between INNER JOIN and FULL JOIN?
INNER JOIN keep only rows that appear in both tables. FULL JOIN will use NULL to fillup those missing values.

6.	What is difference between left join and outer join
LEFT JOIN keep everything  from the table on the left, outer join keep everything from both tables

7.	What is cross join?
CROSS JOIN will join two tables with all the possible combination between rows.

8.	What is the difference between WHERE clause and HAVING clause?
WHERE coms before the GROUP BY and HAVING comes after it. WHERE also get excuted before GROUP BY and HAVING after. WHERE can't take aggrigate and HAVING can only take it.

9.	Can there be multiple group by columns?
Yes
*/

-- Write queries for following scenarios
USE AdventureWorks2019
GO

-- 1.	How many products can you find in the Production.Product table?
SELECT COUNT(*) AS productCount
FROM Production.Product;

-- 2.	Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.
SELECT COUNT(ProductSubcategoryID) AS subcategoryProductCount
FROM Production.Product;

-- 3.	How many Products reside in each SubCategory? Write a query to display the results with the following titles.
/* ProductSubcategoryID CountedProducts
-------------------- --------------- */
SELECT ProductSubcategoryID, COUNT(ProductSubcategoryID) AS CountedProducts
FROM Production.Product
GROUP BY ProductSubcategoryID
ORDER BY CountedProducts DESC;

-- 4.	How many products that do not have a product subcategory. 
SELECT COUNT(ProductSubcategoryID) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NULL;

-- 5.	Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT SUM(Quantity) AS totalProductQuantity
FROM Production.ProductInventory;

-- 6.   Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100.
/*  ProductID    TheSum
-----------        ---------- */
SELECT ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100;

-- 7.	Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100
/*Shelf      ProductID   TheSum
---------- -----------  ----------- */
SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100;

-- 8.	Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table.
SELECT AVG(Quantity) AS averageProductQuantity
FROM Production.ProductInventory
WHERE LocationID = 10;

-- 9.	Write query  to see the average quantity  of  products by shelf  from the table Production.ProductInventory
/* ProductID   Shelf      TheAvg
----------- ---------- -----------*/
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf;

-- 10.	Write query  to see the average quantity  of  products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory
/* ProductID   Shelf      TheAvg
----------- ---------- -----------*/
SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE Shelf != 'N/A'
GROUP BY ProductID, Shelf;

-- 11.	List the members (rows) and average list price in the Production.Product table. This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.
/* Color         Class 	TheCount   	    AvgPrice
--------------	------ 	----------- 	---------------------*/
SELECT Color, Class, COUNT(*) AS TheCount, AVG(ListPrice)
FROM Production.Product
WHERE Color IS NOT NULL
	AND Class IS NOT NULL
GROUP BY Color, Class;

-- 12.	  Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the following. 
/*Country         Province
---------       ---------------------- */
SELECT cr.Name AS Country, sp.Name AS Province
FROM person.CountryRegion cr
JOIN person.StateProvince sp
ON cr.CountryRegionCode = sp.CountryRegionCode
ORDER BY Country, Province;

-- 13.	Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.
/* Country              Province
---------             ---------------------- */
SELECT cr.Name AS Country, sp.Name AS Province
FROM person.CountryRegion cr
JOIN person.StateProvince sp
ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE cr.Name IN ('Germany','Canada')
ORDER BY Country, Province;

USE Northwind
GO
-- 14.	List all Products that has been sold at least once in last 25 years.
SELECT DISTINCT p.ProductName
FROM dbo.Orders o
LEFT JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
LEFT JOIN dbo.Products p ON od.ProductID = p.ProductID
WHERE YEAR(o.OrderDate) > YEAR(GETDATE()) - 25
ORDER BY p.ProductName;

-- 15.	List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 ShipPostalCode, COUNT(*) AS orderCount
FROM dbo.Orders
WHERE ShipPostalCode IS NOT NULL
GROUP BY ShipPostalCode
ORDER BY orderCount DESC;

-- 16.	List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT TOP 5 ShipPostalCode, COUNT(*) AS orderCount
FROM dbo.Orders
WHERE YEAR(OrderDate) > YEAR(GETDATE()) - 25 
	AND ShipPostalCode IS NOT NULL
GROUP BY ShipPostalCode
ORDER BY orderCount DESC;

-- 17.	 List all city names and number of customers in that city.    
SELECT City, COUNT(CustomerID) AS numOfCustomers
FROM dbo.Customers
GROUP BY City
ORDER BY numOfCustomers DESC;

-- 18.	List city names which have more than 2 customers, and number of customers in that city
SELECT City, COUNT(CustomerID) AS numOfCustomers
FROM dbo.Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2
ORDER BY numOfCustomers DESC;

-- 19.	List the names of customers who placed orders after 1/1/98 with order date.
SELECT DISTINCT c.CompanyName
FROM dbo.Orders o
INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderDate > '1998-01-01';

-- 20.	List the names of all customers with most recent order dates 
SELECT c.CompanyName, MAX(o.OrderDate)
FROM dbo.Orders o
INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName
ORDER BY c.CompanyName;

-- 21.	Display the names of all customers  along with the  count of products they bought 
SELECT c.CompanyName, SUM(od.Quantity) AS Total
FROM dbo.Customers c
INNER JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
INNER JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName
ORDER BY c.CompanyName;

-- 22.	Display the customer ids who bought more than 100 Products with count of products.
SELECT o.CustomerID, SUM(od.Quantity) AS Total
FROM dbo.Orders o
INNER JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
HAVING SUM(od.Quantity) > 100;

-- 23.	List all of the possible ways that suppliers can ship their products. Display the results as below
/* Supplier Company Name              	Shipping Company Name
---------------------------------        ---------------------------------- */ 
SELECT DISTINCT sup.CompanyName AS [Sipplier Company Name], ship.CompanyName AS [Shipping Company Name]
FROM dbo.Orders o
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
JOIN dbo.Products p ON od.ProductID = p.ProductID
JOIN dbo.Suppliers sup ON p.SupplierID = sup.SupplierID
JOIN dbo.Shippers ship ON o.ShipVia = ship.ShipperID
ORDER BY 1,2;

-- 24.	Display the products order each day. Show Order date and Product Name.
SELECT DISTINCT o.OrderDate, p.ProductName
FROM dbo.Orders o
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
JOIN dbo.Products p ON od.ProductID = p.ProductID
ORDER BY 1,2;

-- 25.	Displays pairs of employees who have the same job title.
SELECT e1.FirstName + ' ' + e1.LastName AS name1, e2.FirstName + ' ' + e2.LastName AS name2
FROM dbo.Employees e1
JOIN dbo.Employees e2 ON e1.Title = e2.Title
WHERE e1.FirstName != e2.FirstName AND e1.LastName != e2.LastName
ORDER BY 1,2;

-- 26.	Display all the Managers who have more than 2 employees reporting to them.
SELECT e2.FirstName, e2.LastName
FROM dbo.Employees e1
LEFT JOIN dbo.Employees e2 ON e1.ReportsTo = e2.EmployeeID
GROUP BY e2.FirstName, e2.LastName
HAVING COUNT(*) > 2;

-- 27.	Display the customers and suppliers by city. The results should have the following columns
/* City 
Name 
Contact Name,
Type (Customer or Supplier) */

SELECT City, CompanyName, ContactName, 'Customer' AS Type
FROM dbo.Customers
UNION
SELECT City, CompanyName, ContactName, 'Supplier' AS Type
FROM dbo.Suppliers
ORDER BY City