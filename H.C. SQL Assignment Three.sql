/*
1.	In SQL Server, assuming you can find the result by using both joins and subqueries, which one would you prefer to use and why?
Use JOINs, because it cost less

2.	What is CTE and when to use it?
CTE (Common Table Expression) can be use to create a subquery and can be use to do the recurrsion

3.	What are Table Variables? What is their scope and where are they created in SQL Server?
Table variables are similar to the local temp table. They can be use only locally and created in the tempdb inside the system databse

4.	What is the difference between DELETE and TRUNCATE? Which one will have better performance and why?
DELET remove the rows that been selected; TRUNCATE remove every rows in the table. TRUNCATE perform better because it doesn't need to filter out any rows

5.	What is Identity column? How does DELETE and TRUNCATE affect it?


6.	What is difference between ¡§delete from table_name¡¨ and ¡§truncate table table_name¡¨?
for DELETE, we can add more condition to filter out raws
*/

USE NorthWind
GO

-- 1.	List all cities that have both Employees and Customers.
SELECT DISTINCT c.City
FROM dbo.Customers c 
JOIN dbo.Employees e ON c.City = e.City;

-- 2.	List all cities that have Customers but no Employee.
-- a.	Use sub-query
SELECT DISTINCT City
FROM dbo.Customers
WHERE City NOT IN (SELECT DISTINCT City
					FROM dbo.Employees);

-- b.	Do not use sub-query
SELECT DISTINCT c.City
FROM dbo.Customers c 
LEFT JOIN dbo.Employees e ON c.City = e.City
WHERE e.City IS NULL;

-- 3.	List all products and their total order quantities throughout all orders.
SELECT ProductID, SUM(Quantity) AS TotalOrderQuantity
FROM dbo.[Order Details]
GROUP BY ProductID
ORDER BY ProductID;

-- 4.	List all Customer Cities and total products ordered by that city.
SELECT c.City, SUM(od.Quantity) AS TotalOrderQuantity
FROM dbo.Orders o
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.City;

-- 5.	List all Customer Cities that have at least two customers.
SELECT City, COUNT(*) AS CustomerCount
FROM dbo.Customers
GROUP BY City
HAVING COUNT(*) >= 2;
-- a.	Use union


-- b.	Use sub-query and no union
SELECT DISTINCT City
FROM dbo.Customers
WHERE City IN (SELECT City FROM dbo.Customers GROUP BY City HAVING COUNT(*) >= 2);

-- 6.	List all Customer Cities that have ordered at least two different kinds of products.
SELECT c.City, COUNT(od.ProductID) AS ProductCount
FROM dbo.Orders o
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.City
HAVING COUNT(od.ProductID) >= 2;

-- 7.	List all Customers who have ordered products, but have the ¡¥ship city¡¦ on the order different from their own customer cities.
SELECT c.CustomerID, c.City, o.ShipCity
FROM dbo.Customers c
JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
WHERE c.City != o.ShipCity;

-- 8.	List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
WITH popProducts AS (
SELECT TOP 5 ProductID, SUM(Quantity) AS TotalQuantity, AVG(Quantity*(UnitPrice - Discount)) AS avgPrice, MAX(Quantity) AS maxQuantity
FROM dbo.[Order Details]
GROUP BY ProductID
ORDER BY SUM(Quantity) DESC
)
SELECT c.City, pp.*
FROM dbo.[Order Details] od
JOIN popProducts pp ON od.ProductID = pp.ProductID
JOIN dbo.Orders o ON od.OrderID = o.OrderID
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE pp.maxQuantity = od.Quantity
ORDER BY pp.ProductID;

-- 9.	List all cities that have never ordered something but we have employees there.
-- a.	Use sub-query
SELECT DISTINCT City
FROM dbo.Employees
WHERE City IN (
	SELECT c.City
	FROM dbo.Customers c
	LEFT JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
	WHERE o.OrderID IS NULL
	)

-- b.	Do not use sub-query
SELECT e.City
FROM dbo.Employees e
JOIN dbo.Orders o ON e.EmployeeID = o.EmployeeID
LEFT JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE c.City IS NULL

-- 10.	List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
WITH MostOrder AS (
	SELECT TOP 1 c.City, COUNT(o.OrderID) AS OrderCount
	FROM dbo.Orders o
	JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
	GROUP BY c.City
	ORDER BY OrderCount DESC
	)
SELECT m.*, t.TotalQuantity
FROM MostOrder m
JOIN (
	SELECT TOP 1 c.City, SUM(od.Quantity) AS TotalQuantity
	FROM dbo.[Order Details] od
	JOIN dbo.Orders o ON od.OrderID = o.OrderID
	JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
	GROUP BY c.City
	ORDER BY TotalQuantity DESC) t
	ON m.City = t. City;

-- 11.  How do you remove the duplicates record of a table?
/* we can count how many time a row appears by using group by and count or rank function. the we can delet the extra rows with DELET */

-- 12.  Sample table to be used for solutions below- 
/* Employee (empid integer, mgrid integer, deptid integer, salary money) 
Dept (deptid integer, deptname varchar(20)) Find employees who do not manage anybody.
*/
SELECT e1.empid
FROM Employee e1
LEFT JOIN Employee e2 ON e1.empid = e2.mgrid
WHERE e2.mgrid IS NULL

-- 13. Find departments that have maximum number of employees. (solution should consider scenario having more than 1 departments that have maximum number of employees). Result should only have - deptname, count of employees sorted by deptname.
SELECT temp.deptname, temp.[Count Of Employees]
FROM (
	SELECT d.deptname, COUNT(e.empid) AS [Count Of Employees], RANK() OVER (ORDER BY COUNT(e.empid) DESC) AS numRank
	FROM Dept d
	JOIN Employee e ON d.deptid = e.deptid
	GROUP BY d.deptname
	) temp
WHERE temp.numRank = 1;

-- 14. Find top 3 employees (salary based) in every department. Result should have deptname, empid, salary sorted by deptname and then employee with high to low salary.
SELECT temp.deptname, temp.empid, temp.salary
FROM (SELECT d.deptname, e.empid, e.salary, RANK() OVER (PARTITION BY d.deptname ORDER BY salary DESC) AS salaryRank
	FROM Employee e
	JOIN Dept d ON e.deptid = d.deptid
	) temp
WHERE temp.salaryRank <= 3;
