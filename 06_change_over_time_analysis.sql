USE CoffeeSales;
GO

/*
===========================================================
06. CHANGE OVER TIME ANALYSIS
===========================================================

Purpose:
    Analyze how sales performance changes over time by
    examining monthly and yearly trends, month-over-month
    differences, growth rates, and performance rankings.

SQL Concepts Used:
    - Aggregate functions
    - Common Table Expressions
    - Date functions
    - Window functions
    - LAG
    - RANK
    - CASE expressions
*/

-- ========================================================
-- Question 1:
-- How have sales changed each month?
-- ========================================================

SELECT
    DATETRUNC(MONTH, order_date) AS order_month,

    -- Formato visual para facilitar la lectura.
    FORMAT(DATETRUNC(MONTH, order_date), 'MMM yyyy') AS month_year,

    SUM(sales) AS monthly_sales
FROM gold.fact_orders
GROUP BY
    DATETRUNC(MONTH, order_date)
ORDER BY
    order_month;



-- ========================================================
-- Question 2:
-- How do monthly sales compare with the previous month?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
)

SELECT
    order_month,

    -- Columna visual.
    FORMAT(order_month, 'MMM yyyy') AS month_year,

    monthly_sales,

    LAG(monthly_sales, 1) OVER (
        ORDER BY order_month
    ) AS previous_month_sales
FROM MonthlySales
ORDER BY
    order_month;



-- ========================================================
-- Question 3:
-- What is the sales difference between the current month
-- and the previous month?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

PreviousMonthSales AS (
    SELECT
        order_month,
        monthly_sales,

        LAG(monthly_sales, 1) OVER (
            ORDER BY order_month
        ) AS previous_month_sales
    FROM MonthlySales
)

SELECT
    order_month,

    -- Solo se utiliza para presentar el mes de forma legible.
    FORMAT(order_month, 'MMM yyyy') AS month_year,

    monthly_sales,
    previous_month_sales,

    -- Cálculo fila por fila; no necesita GROUP BY.
    monthly_sales - previous_month_sales AS sales_difference
FROM PreviousMonthSales
ORDER BY
    order_month;



-- ========================================================
-- Question 4:
-- What is the month-over-month sales growth percentage?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

PreviousMonthSales AS (
    SELECT
        order_month,
        monthly_sales,

        LAG(monthly_sales, 1) OVER (
            ORDER BY order_month
        ) AS previous_month_sales
    FROM MonthlySales
)

SELECT
    order_month,
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_sales,
    previous_month_sales,

    ROUND(
        (
            (monthly_sales - previous_month_sales)
            / NULLIF(previous_month_sales, 0)
        ) * 100,
        2
    ) AS growth_percentage
FROM PreviousMonthSales
ORDER BY
    order_month;

-- ========================================================
-- Question 5:
-- How have sales changed each year?
-- ========================================================

SELECT
    YEAR(order_date) AS order_year,
    SUM(sales) AS yearly_sales
FROM gold.fact_orders
GROUP BY
    YEAR(order_date)
ORDER BY
    order_year;


-- ========================================================
-- Question 6:
-- Which month had the highest sales?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

MonthRank AS (
    SELECT
        order_month,
        monthly_sales,

        -- DESC coloca las ventas más altas en el rango 1.
        RANK() OVER (
            ORDER BY monthly_sales DESC
        ) AS month_rank
    FROM MonthlySales
)

SELECT
    order_month,
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_sales
FROM MonthRank
WHERE month_rank = 1
ORDER BY
    order_month;



-- ========================================================
-- Question 7:
-- Which month had the lowest sales?
-- ========================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

MonthRank AS (
    SELECT
        order_month,
        monthly_sales,

        -- ASC coloca las ventas más bajas en el rango 1.
        RANK() OVER (
            ORDER BY monthly_sales ASC
        ) AS month_rank
    FROM MonthlySales
)

SELECT
    order_month,
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_sales
FROM MonthRank
WHERE month_rank = 1
ORDER BY
    order_month;


-- ========================================================
-- Question 8:
-- How did monthly sales trend compared with the previous month
-- ========================================================


WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

PreviousMonthSales AS (
    SELECT
        order_month,
        monthly_sales,

        -- Recupera las ventas del mes anterior.
        LAG(monthly_sales, 1) OVER (
            ORDER BY order_month
        ) AS previous_month_sales
    FROM MonthlySales
)

SELECT
    -- Fecha real utilizada para ordenar y hacer cálculos.
    order_month,

    -- Formato visual más fácil de leer.
    FORMAT(order_month, 'MMM yyyy') AS month_year,

    monthly_sales,
    previous_month_sales,

    -- Crecimiento porcentual respecto al mes anterior.
    ROUND(
        (
            (monthly_sales - previous_month_sales)
            / NULLIF(previous_month_sales, 0)
        ) * 100,
        2
    ) AS growth_percentage,

    -- Clasifica la tendencia de cada mes.
    CASE
        WHEN previous_month_sales IS NULL THEN 'No Previous Month'
        WHEN monthly_sales > previous_month_sales THEN 'Increasing'
        WHEN monthly_sales < previous_month_sales THEN 'Decreasing'
        ELSE 'No Change'
    END AS trend

FROM PreviousMonthSales
ORDER BY
    order_month;
