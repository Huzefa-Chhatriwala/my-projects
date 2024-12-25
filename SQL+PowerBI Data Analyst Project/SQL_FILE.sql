CREATE TABLE pizza_sales (
    pizza_id SERIAL PRIMARY KEY,
    order_id INT,
    pizza_name_id VARCHAR(15),
    quantity INT,
    order_date TEXT,
    order_time TIME,
    unit_price DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    pizza_size CHAR(3),
    pizza_category VARCHAR(20),
    pizza_ingredients VARCHAR(100),
    pizza_name VARCHAR(50)
);

-- \copy pizza_sales (pizza_id, order_id, pizza_name_id, quantity, order_date, order_time, unit_price, total_price, pizza_size, pizza_category, pizza_ingredients, pizza_name)
-- FROM 'C:\\Users\\Huzefa\\OneDrive\\Documents\\Mysql\\Pizza Data For SQL & Excel-20241213T130932Z-001\\Pizza Data For SQL & Excel\\pizza_sales.csv'
-- DELIMITER ',' 
-- CSV HEADER;

UPDATE pizza_sales
SET order_date = TO_DATE(order_date, 'DD-MM-YYYY');
ALTER TABLE pizza_sales ALTER COLUMN order_date TYPE DATE USING order_date::DATE;

-- CHECK DATA TYPE OF order_date
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'pizza_sales';
-- another method
SELECT pg_typeof(order_date) AS data_type
FROM pizza_sales
LIMIT 1;

-- checking data
select	*
from pizza_sales 
limit 10;

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

-- KPI QUERY

-- Q1. Total Revenue:
select sum(total_price) as "total_Revenue"
from pizza_sales;

-- Q2. Average Order Value
select (sum(total_price)/ count(distinct(order_id))) as Avg_order_Value 
from pizza_sales; 

-- Q3. Total Pizzas Sold
select sum(quantity) as Total_pizza_sold 
from pizza_sales;

-- Q4. Total Orders
select count(distinct order_id) AS Total_Orders 
from pizza_sales;

--Q5. Average Pizzas Per Order
select	cast(cast(sum(quantity) as decimal(10,2))/
cast(count(distinct order_id) as decimal(10,2))as decimal(10,2)) AS Avg_Pizzas_per_order
from pizza_sales 
limit 10;

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

-- CHARTS QUERY

-- checking data
select	*
from pizza_sales 
limit 10;

-- 1. Daily Trend for Total Orders
select TO_CHAR(order_date, 'Day') as order_day,
	   count(distinct order_id) as total_orders
from pizza_sales
group by TO_CHAR(order_date, 'Day');

-- another method
-- only work on other software not on POSTGRE SQL
SELECT DATENAME(DW, order_date) AS order_day, 
	   COUNT(DISTINCT order_id) AS total_orders 
FROM pizza_sales
GROUP BY DATENAME(DW, order_date);

-- 2. Monthly Trend for Orders
select EXTRACT(MONTH from order_date) as order_month,
	   count(distinct order_id) as total_orders
from pizza_sales
group by EXTRACT(MONTH from order_date);

-- another method
-- only work on other software not on POSTGRE SQL
select DATEPART(HOUR, order_time) as order_hrs,
	   count(distinct order_id) as total_orders
from pizza_sales
group by DATEPART(HOUR, order_time);

-- 3. % of Sales by Pizza Category
SELECT pizza_category, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_category;

-- anathor method
with pizza_1 as (
   select
   pizza_category,
   sum(total_price) as total_Revenue,
   CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
   FROM pizza_sales
   group by pizza_category
)
select distinct pizza_category,
	   total_Revenue,
	   PCT
from pizza_1;

-- 4. % of Sales by Pizza Size
SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_size;

-- 5. Total Pizzas Sold by Pizza Category
select pizza_category, sum(quantity) as Total_Quantity_Sold
from pizza_sales
group by pizza_category;

-- 6. Top 5 Pizzas by Revenue
SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC
limit 5;

-- 7. Bottom 5 Pizzas by Revenue
SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue
limit 5;

-- 8. Top 5 Best Sellers by Quantity
SELECT pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold DESC
limit 5;

-- 9. Bottom 5 Best Sellers by Quantity
SELECT pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold
limit 5;

-- 10. Top 5 Pizzas by Total Orders
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders DESC
limit 5;

-- 11. Top 5 Pizzas by Total Orders
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders
limit 5;






