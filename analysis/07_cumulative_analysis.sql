USE CoffeeSales;
GO

/*
===========================================================
07. CUMULATIVE ANALYSIS
===========================================================

Purpose:
    Analyze accumulated sales performance over time using
    running totals and moving averages.

Business Questions:
    1. What is the cumulative total of sales by month?
    2. What is the cumulative number of orders by month?
    3. What is the cumulative quantity of products sold by month?
    4. What is the three-month moving average of monthly sales?
    5. How do monthly sales compare with the three-month moving average?
    6. What percentage of total sales had been accumulated by each month?
    7. What is the cumulative sales total by coffee type over time?
*/


-- ========================================================
-- Question 1:
-- What is the cumulative total of sales by month?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

CumulativeSales AS (
    SELECT
        order_month,
        monthly_sales,

        SUM(monthly_sales) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_sales

    FROM MonthlySales
)

SELECT
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_sales,
    cumulative_sales
FROM CumulativeSales
ORDER BY
    order_month;


-- ========================================================
-- Question 2:
-- What is the cumulative number of orders by month?
-- ========================================================

WITH MonthlyOrders AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        COUNT(DISTINCT order_id) AS monthly_orders
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

CumulativeOrders AS (
    SELECT
        order_month,
        monthly_orders,

        SUM(monthly_orders) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_orders

    FROM MonthlyOrders
)

SELECT
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_orders,
    cumulative_orders
FROM CumulativeOrders
ORDER BY
    order_month;


-- ========================================================
-- Question 3:
-- What is the cumulative quantity of products sold by month?
-- ========================================================

WITH MonthlyQuantity AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(quantity) AS monthly_quantity
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

CumulativeQuantity AS (
    SELECT
        order_month,
        monthly_quantity,

        SUM(monthly_quantity) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_quantity

    FROM MonthlyQuantity
)

SELECT
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_quantity,
    cumulative_quantity
FROM CumulativeQuantity
ORDER BY
    order_month;


-- ========================================================
-- Question 4:
-- What is the three-month moving average of monthly sales?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

ThreeMonthAverage AS (
    SELECT
        order_month,
        monthly_sales,

        ROW_NUMBER() OVER (
            ORDER BY order_month
        ) AS month_number,

        AVG(monthly_sales) OVER (
            ORDER BY order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS raw_three_month_average

    FROM MonthlySales
)

SELECT
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_sales,

    CASE
        WHEN month_number >= 3
            THEN ROUND(raw_three_month_average, 2)
        ELSE NULL
    END AS three_month_average

FROM ThreeMonthAverage
ORDER BY
    order_month;


-- ========================================================
-- Question 5:
-- How do monthly sales compare with the three-month
-- moving average?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

ThreeMonthAverage AS (
    SELECT
        order_month,
        monthly_sales,

        ROW_NUMBER() OVER (
            ORDER BY order_month
        ) AS month_number,

        AVG(monthly_sales) OVER (
            ORDER BY order_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS raw_three_month_average

    FROM MonthlySales
),

CompletedAverage AS (
    SELECT
        order_month,
        monthly_sales,

        CASE
            WHEN month_number >= 3
                THEN raw_three_month_average
            ELSE NULL
        END AS three_month_average

    FROM ThreeMonthAverage
)

SELECT
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_sales,
    ROUND(three_month_average, 2) AS three_month_average,

    ROUND(
        monthly_sales - three_month_average,
        2
    ) AS difference_from_average,

    ROUND(
        100.0 * (monthly_sales - three_month_average)
        / NULLIF(three_month_average, 0),
        2
    ) AS percentage_difference

FROM CompletedAverage
ORDER BY
    order_month;


-- ========================================================
-- Question 6:
-- What percentage of total sales had been accumulated
-- by each month?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

CalculatedSales AS (
    SELECT
        order_month,
        monthly_sales,

        SUM(monthly_sales) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_sales,

        SUM(monthly_sales) OVER () AS total_sales

    FROM MonthlySales
)

SELECT
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_sales,
    cumulative_sales,
    total_sales,

    ROUND(
        100.0 * cumulative_sales
        / NULLIF(total_sales, 0),
        2
    ) AS accumulated_percentage

FROM CalculatedSales
ORDER BY
    order_month;


-- ========================================================
-- Question 7:
-- What is the cumulative sales total by coffee type
-- over time?
-- ========================================================

WITH MonthlyCoffeeSales AS (
    SELECT
        DATETRUNC(MONTH, f.order_date) AS order_month,
        p.coffee_type,
        SUM(f.sales) AS monthly_sales

    FROM gold.fact_orders AS f

    INNER JOIN gold.dim_products AS p
        ON f.product_key = p.product_key

    -- One row per month and coffee type.
    GROUP BY
        DATETRUNC(MONTH, f.order_date),
        p.coffee_type
),

CumulativeCoffeeSales AS (
    SELECT
        order_month,
        coffee_type,
        monthly_sales,

        -- The cumulative total restarts for each coffee type.
        SUM(monthly_sales) OVER (
            PARTITION BY coffee_type
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_sales

    FROM MonthlyCoffeeSales
)

SELECT
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    coffee_type,
    monthly_sales,
    cumulative_sales
FROM CumulativeCoffeeSales
ORDER BY
    coffee_type,
    order_month;
