/*1.	What is View? What are the benefits of using views?
View is a table that created by query other tables. It can display tables to user without showing the process and the whole table

2.	Can data be modified through views?
Yes, it will modified the orginial table directly theough view

3.	What is stored procedure and what are the benefits of using it?
Is the stored user defined / system defined functions that can be called at anytime.

4.	What is the difference between view and stored procedure?
view canonly contains a table. stored procedure can return anything

5.	What is the difference between stored procedure and functions?
stored procedure can be called with EXEC; function can be called in SELECT or in SP

6.	Can stored procedure return multiple result sets?
It can return a table

7.	Can stored procedure be executed as part of SELECT Statement? Why?
No, it can be only EXEC by itself

8.	What is Trigger? What types of Triggers are there?
Trigger will be excute when meet some condition (ex. DELETE, INSERT)

9.	What is the difference between Trigger and Stored Procedure?
triger can't be called but sp can, and sp can also return object
*/

USE Northwind
GO

-- 1.	Create a view named ¡§view_product_order_[your_last_name]¡¨, list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_Chen AS 
SELECT ProductID, SUM(Quantity) AS TotalOrderQuantity
FROM dbo.[Order Details]
GROUP BY ProductID

SELECT *
FROM view_product_order_Chen

-- 2.	Create a stored procedure ¡§sp_product_order_quantity_[your_last_name]¡¨ that accept product id as an input and total quantities of order as output parameter.
CREATE PROC sp_product_order_quantity_Chen 
@productID int,
@totalOrderQuantity int out 
AS 
SELECT @totalOrderQuantity = SUM(Quantity)
FROM dbo.[Order Details]
WHERE ProductID = @productID
GROUP BY ProductID

BEGIN
DECLARE @Q int
EXEC sp_product_order_quantity_Chen 23, @Q out
PRINT @Q
END

-- 3.	Create a stored procedure ¡§sp_product_order_city_[your_last_name]¡¨ that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
CREATE PROC sp_product_order_city_Chen 
@productName varchar(20)
AS 
SELECT TOP 5 c.City, SUM(od.Quantity) AS TotalOrderQuantity
FROM dbo.[Order Details] od
JOIN dbo.Products p ON od.ProductID = p.ProductID
JOIN dbo.Orders o ON od.OrderID = o.OrderID
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE p.ProductName = @productName
GROUP BY c.City
ORDER BY TotalOrderQuantity DESC

EXEC sp_product_order_city_Chen 'Chai'

-- 4.	Create 2 new tables ¡§people_your_last_name¡¨ ¡§city_your_last_name¡¨. City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. If there was anyone from Seattle, put them into a new city ¡§Madison¡¨. Create a view ¡§Packers_your_name¡¨ lists all people from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
CREATE TABLE city_Chen (
	Id INT PRIMARY KEY,
	City varchar(20)
);

CREATE TABLE people_Chen (
	Id INT PRIMARY KEY,
	Name varchar(20),
	City INT FOREIGN KEY REFERENCES city_Chen(Id) ON DELETE SET NULL
);

INSERT INTO dbo.city_Chen
VALUES (1, 'Seattle'),
	   (2, 'Green Bay');

SELECT * FROM dbo.city_Chen;

INSERT INTO dbo.people_Chen
VALUES (1, 'Aaron Rodgers', 2),
	   (2, 'Russell Wilson', 1),
	   (3, 'Jody Nelson', 2);

SELECT * FROM dbo.people_Chen;

DELETE FROM dbo.city_Chen
WHERE City = 'Seattle';

INSERT INTO dbo.city_Chen VALUES (3, 'Madison');

UPDATE dbo.people_Chen
SET City = 3
WHERE City IS NULL

CREATE VIEW Packers_Chen AS 
SELECT p.*
FROM dbo.people_Chen p
JOIN dbo.city_Chen c ON p.City = c.Id
WHERE c.City = 'Green Bay';

SELECT * FROM Packers_Chen;

DROP TABLE dbo.people_Chen;
DROP TABLE dbo.city_Chen;
DROP VIEW Packers_Chen;

-- 5.  Create a stored procedure ¡§sp_birthday_employees_[you_last_name]¡¨ that creates a new table ¡§birthday_employees_your_last_name¡¨ and fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
CREATE PROC sp_birthday_employees_Chen AS
BEGIN
CREATE TABLE birthday_employees_Chen (
	EmployessID INT PRIMARY KEY,
	LastName VARCHAR(20),
	FisrName VARCHAR(20),
	BirthDate DATETIME
	)
INSERT INTO birthday_employees_Chen
SELECT EmployeeID, LastName, FirstName, BirthDate
FROM dbo.Employees
WHERE MONTH(BirthDate) = 2
END;

EXEC sp_birthday_employees_Chen;

SELECT * FROM birthday_employees_Chen;

DROP TABLE birthday_employees_Chen;

-- 6.	How do you make sure two tables have the same data?
-- USE UNION. If the row count increased, there are different data

-- 7.
/*First Name	Last Name	Middle Name
   John	          Green	
   Mike	          White	        M
Output should be
  Full Name
  John Green
  Mike White M.
Note: There is a dot after M when you output. */
SELECT (CASE 
			WHEN [Middle Name] IS NULL THEN [First Name] + ' ' + [Last Name]
			ELSE [First Name] + ' ' + [Last Name] + ' ' + [Middle Name] + '.'
		END) AS [Full Name]
FROM [the table]

-- 8.
/*Student	Marks	Sex
	Ci	     70	     F
	Bob	     80	     M
	Li	     90	     F
	Mi	     95    	M
Find the top marks of Female students.
If there are to students have the max score, only output one. */
SELECT TOP 1 Marks
FROM [The table]
WHERE Sex = 'F'
ORDER BY Marks DESC;

-- 9. 
/*Student	Marks	Sex
	Li     	90	     F
	Ci	    70	     F
	Mi	    95	     M
	Bob	    80	     M
How do you out put this? */
SELECT *
FROM [The table]
ORDER BY Sex, Marks DESC