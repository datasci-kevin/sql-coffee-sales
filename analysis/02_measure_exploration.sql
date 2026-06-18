/*
===============================================================================
02 - Measure Exploration
===============================================================================
Purpose:
    Calculate high-level business measures such as sales, quantity, orders,
    products, and customers.
===============================================================================
*/

-- Find the total Sales
SELECT
	SUM(sales) AS total_sales 
FROM
	gold.fact_orders;

-- Find how many items are sold
SELECT
	SUM(quantity) AS total_items_sold
FROM
	gold.fact_orders;

-- Find the average selling price
SELECT
	ROUND(AVG(sales), 2) AS average_order
FROM
	gold.fact_orders; -- returns me this number 45.140000 is that right as a number is that because of how we set up the number for it at the beginning.

-- Find the total number of orders
SELECT
	COUNT(order_id) AS total_orders 
FROM
	gold.fact_orders;


-- Build a simple KPI summary report.
SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value FROM gold.fact_orders
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_orders
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_id) FROM gold.fact_orders
UNION ALL
SELECT 'Total Customers With Orders', COUNT(DISTINCT customer_key) FROM gold.fact_orders;
