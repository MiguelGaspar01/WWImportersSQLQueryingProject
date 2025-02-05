-- 1.	How many sales orders were placed per year?

WITH YearColumnSeparate 
AS
(
SELECT [Order Date Key], YEAR([Order Date Key]) AS year_date, COUNT(*) as [Number of Orders]
FROM [Fact].[Order]
GROUP BY [Order Date Key]
)
SELECT year_date, SUM([Number of Orders]) as count_orders
FROM YearColumnSeparate
GROUP BY year_date
ORDER BY year_date DESC;


-- 2.	What are the top 10 customers with the highest total order value?

WITH Customer_Expenses 
AS
(
SELECT [Customer Key] AS customer, 
SUM([Total Excluding Tax]) AS [total excluding tax],
SUM([Total Including Tax]) AS [total including tax] 

FROM [Fact].[Order]
GROUP BY [Customer Key]
)
SELECT TOP 10 * 
FROM Customer_Expenses
ORDER BY [total including tax];

--3.	Which products have never been sold?

SELECT DISTINCT si.[Stock Item Key], si.[Stock Item] AS item_name
FROM [Dimension].[Stock Item] si
LEFT JOIN [Fact].[Sale] S
ON si.[Stock Item Key] = s.[Stock Item Key]
WHERE s.[Stock Item Key] IS NULL AND si.[Stock Item Key] != 0
ORDER BY [Stock Item Key];

--4.	What are the orders that were placed on a Monday?

SELECT [Order Key], DATENAME(WEEKDAY, d.[Date]) AS [Weekday Name]
FROM [Fact].[Order] o
JOIN [Dimension].[Date] d
ON d.[Date] = o.[Order Date Key]
WHERE DATENAME(WEEKDAY, d.[Date]) = 'Monday';

--5.	What is the total revenue (excluding tax) per year?

SELECT YEAR(f.[Invoice Date Key]) AS year_sales, SUM(f.[Total Excluding Tax]) AS total_revenue
FROM [Fact].[Sale] f
GROUP BY YEAR(f.[Invoice Date Key])
ORDER BY YEAR(f.[Invoice Date Key]);

--6.	Which product category generates the most revenue?

WITH Category_Items
AS
(
SELECT DISTINCT sup.[Category], m.[Stock Item Key]
FROM [Dimension].[Supplier] sup
INNER JOIN [Fact].[Movement] m
ON sup.[Supplier Key] = m.[Supplier Key]
WHERE sup.[Category] != 'N/A'
),
AggregatedSalesPerItem
AS
(
SELECT sa.[Stock Item Key], SUM(sa.[Profit]) as total_profit
FROM [Fact].[Sale] sa
GROUP BY sa.[Stock Item Key]
)
SELECT ci.[Category], 
SUM(sa.total_profit) AS Revenue, 
DENSE_RANK() OVER(ORDER BY SUM(sa.total_profit) DESC) as Rank_Profit
FROM Category_Items ci
INNER JOIN AggregatedSalesPerItem sa  
ON ci.[Stock Item Key] = sa.[Stock Item Key]
GROUP BY ci.[Category]
ORDER BY Revenue DESC;

--7.	What is the average order value per month?

SELECT d.[Month], AVG(o.[Total Including Tax]) as Average_Order_Value
FROM [Dimension].[Date] d
INNER JOIN [Fact].[Order] o
ON d.[Date] = o.[Order Date Key]
GROUP BY d.[Month],  MONTH(d.[Date])
ORDER BY MONTH(d.[Date])	

--8.	How many distinct customers placed orders each year?

SELECT YEAR(d.[Date]) AS date_year,
COUNT(DISTINCT o.[Customer Key]) AS Count_Of_Customers
FROM [Fact].[Order] o
INNER JOIN [Dimension].[Date] d
ON o.[Order Date Key] = d.[Date]
GROUP BY YEAR(d.[Date])
ORDER BY YEAR(d.[Date]);

--9. What is the most common payment method used for purchases?

SELECT [Payment Method], COUNT(*) count_of_payment_occurences
FROM [Dimension].[Payment Method] pm
INNER JOIN [Fact].[Transaction] t
on t.[Payment Method Key] = pm.[Payment Method Key]
WHERE [Payment Method] != 'Unknown'
GROUP BY [Payment Method]
ORDER BY count_of_payment_occurences DESC;

--10. Who are the top 5 suppliers based on the total value of supplied products?

WITH Item_Prices AS
(
SELECT sa.[Stock Item Key], AVG(sa.[Unit Price]) as avg_price, m.[Supplier Key]
FROM [Fact].[Sale] sa
INNER JOIN [Fact].[Movement] m
ON m.[Stock Item Key] = sa.[Stock Item Key]
GROUP BY sa.[Stock Item Key],  m.[Supplier Key] 
)
SELECT TOP 5 [Supplier Key], SUM(avg_price) 
FROM Item_Prices ip
INNER JOIN [Fact].[Sale] sa
ON sa.[Stock Item Key] = ip.[Stock Item Key]
GROUP BY ([Supplier Key])
ORDER BY SUM(avg_price) DESC;

--11.	What do the orders that were placed by customers located in the United States look like?

SELECT c.[Customer], o.[Order Key], ci.[Country], o.[Description], o.[Quantity]
FROM [Dimension].[Customer] c
INNER JOIN [Fact].[Order] o
ON o.[Customer Key] = c.[Customer Key]
INNER JOIN [Dimension].[City] ci
ON o.[City Key] = ci.[City Key]
WHERE c.[Customer] != 'Unknown' AND ci.[Country] = 'United States'
GROUP BY c.[Customer], ci.[Country], o.[Order Key], o.[Description], o.[Quantity]
ORDER BY c.[Customer];

--12. 	Whats the most purchased product per customer?

WITH UniquePurchasedItems 
AS
(
SELECT si.[Stock Item Key], si.[Stock Item], p.[Is Order Finalized]
FROM [Dimension].[Stock Item] si
INNER JOIN [Fact].[Purchase] p
ON si.[Stock Item Key] = p.[Stock Item Key]
),
CustomerOrdersConcluded
AS
(
SELECT c.[Customer Key], u.[Stock Item], COUNT(*) as purchase_count, ROW_NUMBER() OVER (PARTITION BY c.[Customer Key] ORDER BY COUNT(*) DESC) AS rn
FROM UniquePurchasedItems u
INNER JOIN [Fact].[Order] o
ON o.[Stock Item Key] = u.[Stock Item Key]
INNER JOIN [Dimension].[Customer] c
ON o.[Customer Key] = c.[Customer Key]
WHERE u.[Is Order Finalized] = 1
GROUP BY c.[Customer Key], u.[Stock Item]
)
SELECT cod.[Customer Key], cod.[Stock Item], cod.purchase_count
FROM CustomerOrdersConcluded cod
WHERE rn = 1;

-- 13.	Whats the city that generates the highest sales revenue?

SELECT TOP 1 c.[City], SUM(sa.[Total Including Tax]) as sum_of_revenue
FROM [Dimension].[City] c
INNER JOIN [Fact].[Sale] sa
ON c.[City Key] = sa.[City Key]
GROUP BY c.[City]
ORDER BY sum_of_revenue DESC;

--14.  Which employees have processed the highest number of orders?

WITH EmployeeOrderCounts 
AS
(
SELECT e.[Employee Key] , 
COUNT(*) as [Nr of Orders], 
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as [Rank of Employee]
FROM [Dimension].[Employee] e
INNER JOIN [Fact].[Order] o
ON o.[Salesperson Key] = e.[Employee Key]
WHERE e.[Is Salesperson] = 1
GROUP BY e.[Employee Key]
)
SELECT * FROM EmployeeOrderCounts
WHERE [Rank of Employee] < 6
ORDER BY [Rank of Employee], [Nr of Orders] DESC;

--15. What is the the percentage of stock items that were ordered more than once.

WITH OrderCountsForItems
AS
(
SELECT si.[Stock Item Key], si.[Stock Item], COUNT(o.[Order Key]) as order_number
FROM [Fact].[Order] o
RIGHT JOIN [Dimension].[Stock Item] si
on o.[Stock Item Key] = si.[Stock Item Key]
WHERE si.[Stock Item Key] != 0
GROUP BY si.[Stock Item Key], si.[Stock Item]
),
re_ordered as
(
SELECT *, CASE WHEN ocf.order_number = 0 THEN 0 ELSE 1 END AS is_re_ordered
FROM OrderCountsForItems ocf
)
SELECT COUNT(CASE WHEN is_re_ordered = 1 THEN 1 END) * 100.0/COUNT(*) AS [Reorder Percentage]
from re_ordered;
