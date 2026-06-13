/*
===============================================================================
DATE RANGE EXPLORATION
===============================================================================
Purpose:
    Understand the time period covered by the sales data.
===============================================================================
*/

-- Find the first and last order date
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM gold.fact_orders;

-- Find how many years, months, and days of sales are available
SELECT
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months,
    DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS order_range_days
FROM gold.fact_orders;

-- Count orders by year
SELECT
    YEAR(order_date) AS order_year,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales
FROM gold.fact_orders
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Count orders by month
SELECT
    FORMAT(order_date, 'yyyy-MM') AS order_month,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales
FROM gold.fact_orders
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY order_month;




