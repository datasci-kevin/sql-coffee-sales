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

-- Find the average order value
SELECT
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM gold.fact_orders;

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
SELECT 'Total Customers With Orders', COUNT(DISTINCT customer_key) FROM gold.fact_orders
UNION ALL
SELECT 'Average Order Value', ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) FROM gold.fact_orders;
