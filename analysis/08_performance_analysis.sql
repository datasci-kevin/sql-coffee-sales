USE CoffeeSales;
GO

/*
===============================================================================
08. PERFORMANCE ANALYSIS
===============================================================================

Purpose:
    Evaluate business performance by comparing sales results against
    averages, benchmarks, rankings, and customer segments.

Business Questions:
    1. Which products perform above or below average product sales?
    2. Which customers spend above or below average customer spending?
    3. Which months perform above or below average monthly sales?
    4. Which coffee types generate above-average sales?
    5. Which countries generate above-average sales?
    6. How far is each product above or below average product sales?
    7. Which products belong to the top 20% based on sales?
    8. Which roast types generate above-average sales?
    9. Which size categories generate above-average sales?
   10. How do loyalty and non-loyalty customers perform?
===============================================================================
*/


-- =============================================================================
-- Question 1:
-- Which products perform above or below average product sales?
-- =============================================================================

WITH ProductSales AS (
    SELECT
        p.product_id,
        SUM(o.sales) AS product_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY
        p.product_id
),

AverageProductSales AS (
    SELECT
        product_id,
        product_sales,
        AVG(product_sales) OVER () AS average_product_sales
    FROM ProductSales
)

SELECT
    product_id,
    product_sales,
    ROUND(average_product_sales, 2) AS average_product_sales,

    CASE
        WHEN product_sales > average_product_sales THEN 'Above Average'
        WHEN product_sales < average_product_sales THEN 'Below Average'
        ELSE 'Average'
    END AS product_performance

FROM AverageProductSales
ORDER BY
    product_sales DESC;


-- =============================================================================
-- Question 2:
-- Which customers spend above or below average customer spending?
-- =============================================================================

WITH CustomerSales AS (
    SELECT
        c.customer_key,
        c.customer_name,
        SUM(o.sales) AS customer_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY
        c.customer_key,
        c.customer_name
),

AverageCustomerSales AS (
    SELECT
        customer_key,
        customer_name,
        customer_sales,
        AVG(customer_sales) OVER () AS average_customer_sales
    FROM CustomerSales
)

SELECT
    customer_key,
    customer_name,
    customer_sales,
    ROUND(average_customer_sales, 2) AS average_customer_sales,

    CASE
        WHEN customer_sales > average_customer_sales THEN 'Above Average'
        WHEN customer_sales < average_customer_sales THEN 'Below Average'
        ELSE 'Average'
    END AS customer_performance,

    ROUND(
        100.0 * (customer_sales - average_customer_sales)
        / NULLIF(average_customer_sales, 0),
        2
    ) AS percentage_variance_from_average,

    RANK() OVER (
        ORDER BY customer_sales DESC
    ) AS customer_rank

FROM AverageCustomerSales
ORDER BY
    customer_rank;


-- =============================================================================
-- Question 3:
-- Which months perform above or below average monthly sales?
-- =============================================================================

WITH MonthlySales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales) AS monthly_sales
    FROM gold.fact_orders
    GROUP BY
        DATETRUNC(MONTH, order_date)
),

AverageMonthlySales AS (
    SELECT
        order_month,
        monthly_sales,
        AVG(monthly_sales) OVER () AS average_monthly_sales
    FROM MonthlySales
)

SELECT
    order_month,
    FORMAT(order_month, 'MMM yyyy') AS month_year,
    monthly_sales,
    ROUND(average_monthly_sales, 2) AS average_monthly_sales,

    CASE
        WHEN monthly_sales > average_monthly_sales THEN 'Above Average'
        WHEN monthly_sales < average_monthly_sales THEN 'Below Average'
        ELSE 'Average'
    END AS monthly_performance

FROM AverageMonthlySales
ORDER BY
    order_month;


-- =============================================================================
-- Question 4:
-- Which coffee types generate above-average sales?
-- =============================================================================

WITH CoffeeTypeSales AS (
    SELECT
        p.coffee_type,
        SUM(o.sales) AS coffee_type_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY
        p.coffee_type
),

AverageCoffeeTypeSales AS (
    SELECT
        coffee_type,
        coffee_type_sales,
        AVG(coffee_type_sales) OVER () AS average_coffee_type_sales
    FROM CoffeeTypeSales
)

SELECT
    coffee_type,
    coffee_type_sales,
    ROUND(average_coffee_type_sales, 2) AS average_coffee_type_sales,

    CASE
        WHEN coffee_type_sales > average_coffee_type_sales THEN 'Above Average'
        WHEN coffee_type_sales < average_coffee_type_sales THEN 'Below Average'
        ELSE 'Average'
    END AS coffee_type_performance

FROM AverageCoffeeTypeSales
ORDER BY
    coffee_type_sales DESC;


-- =============================================================================
-- Question 5:
-- Which countries generate above-average sales?
-- =============================================================================

WITH CountrySales AS (
    SELECT
        c.country,
        SUM(o.sales) AS country_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY
        c.country
),

AverageCountrySales AS (
    SELECT
        country,
        country_sales,
        AVG(country_sales) OVER () AS average_country_sales
    FROM CountrySales
)

SELECT
    country,
    country_sales,
    ROUND(average_country_sales, 2) AS average_country_sales,

    CASE
        WHEN country_sales > average_country_sales THEN 'Above Average'
        WHEN country_sales < average_country_sales THEN 'Below Average'
        ELSE 'Average'
    END AS country_performance

FROM AverageCountrySales
ORDER BY
    country_sales DESC;


-- =============================================================================
-- Question 6:
-- How far is each product above or below average product sales?
-- =============================================================================

WITH ProductSales AS (
    SELECT
        p.product_id,
        SUM(o.sales) AS product_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY
        p.product_id
),

AverageProductSales AS (
    SELECT
        product_id,
        product_sales,
        AVG(product_sales) OVER () AS average_product_sales
    FROM ProductSales
)

SELECT
    product_id,
    product_sales,
    ROUND(average_product_sales, 2) AS average_product_sales,

    ROUND(
        product_sales - average_product_sales,
        2
    ) AS difference_from_average,

    ROUND(
        100.0 * (product_sales - average_product_sales)
        / NULLIF(average_product_sales, 0),
        2
    ) AS percentage_difference_from_average,

    CASE
        WHEN product_sales > average_product_sales THEN 'Above Average'
        WHEN product_sales < average_product_sales THEN 'Below Average'
        ELSE 'Average'
    END AS product_performance

FROM AverageProductSales
ORDER BY
    product_sales DESC;


-- =============================================================================
-- Question 7:
-- Which products belong to the top 20% based on sales?
-- =============================================================================

WITH ProductSales AS (
    SELECT
        p.product_id,
        SUM(o.sales) AS product_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY
        p.product_id
),

ProductQuintiles AS (
    SELECT
        product_id,
        product_sales,

        -- Divides products into five approximately equal sales groups.
        -- Quintile 1 represents the top 20%.
        NTILE(5) OVER (
            ORDER BY product_sales DESC
        ) AS sales_quintile

    FROM ProductSales
)

SELECT
    product_id,
    product_sales,
    sales_quintile
FROM ProductQuintiles
WHERE sales_quintile = 1
ORDER BY
    product_sales DESC;


-- =============================================================================
-- Question 8:
-- Which roast types generate above-average sales?
-- =============================================================================

WITH RoastTypeSales AS (
    SELECT
        p.roast_type,
        SUM(o.sales) AS roast_type_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY
        p.roast_type
),

AverageRoastTypeSales AS (
    SELECT
        roast_type,
        roast_type_sales,
        AVG(roast_type_sales) OVER () AS average_roast_type_sales
    FROM RoastTypeSales
)

SELECT
    roast_type,
    roast_type_sales,
    ROUND(average_roast_type_sales, 2) AS average_roast_type_sales,

    CASE
        WHEN roast_type_sales > average_roast_type_sales THEN 'Above Average'
        WHEN roast_type_sales < average_roast_type_sales THEN 'Below Average'
        ELSE 'Average'
    END AS roast_type_performance

FROM AverageRoastTypeSales
ORDER BY
    roast_type_sales DESC;


-- =============================================================================
-- Question 9:
-- Which size categories generate above-average sales?
-- =============================================================================

WITH SizeCategorySales AS (
    SELECT
        p.size_category,
        SUM(o.sales) AS size_category_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key

    -- The required granularity is one row per size category,
    -- so product_key must not be included in the GROUP BY.
    GROUP BY
        p.size_category
),

AverageSizeCategorySales AS (
    SELECT
        size_category,
        size_category_sales,
        AVG(size_category_sales) OVER () AS average_size_category_sales
    FROM SizeCategorySales
)

SELECT
    size_category,
    size_category_sales,
    ROUND(average_size_category_sales, 2) AS average_size_category_sales,

    CASE
        WHEN size_category_sales > average_size_category_sales
            THEN 'Above Average'
        WHEN size_category_sales < average_size_category_sales
            THEN 'Below Average'
        ELSE 'Average'
    END AS size_category_performance

FROM AverageSizeCategorySales
ORDER BY
    size_category_sales DESC;


-- =============================================================================
-- Question 10:
-- How do loyalty and non-loyalty customers perform?
-- =============================================================================

WITH LoyaltyPerformance AS (
    SELECT
        c.loyalty_card,

        -- DISTINCT prevents customers or orders from being counted
        -- multiple times because the fact table contains order lines.
        COUNT(DISTINCT c.customer_key) AS total_customers,
        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(o.quantity) AS total_quantity,
        SUM(o.sales) AS total_sales

    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key

    GROUP BY
        c.loyalty_card
)

SELECT
    loyalty_card,
    total_customers,
    total_orders,
    total_quantity,
    total_sales,

    ROUND(
        1.0 * total_sales
        / NULLIF(total_customers, 0),
        2
    ) AS average_sales_per_customer,

    ROUND(
        1.0 * total_sales
        / NULLIF(total_orders, 0),
        2
    ) AS average_order_value,

    ROUND(
        1.0 * total_orders
        / NULLIF(total_customers, 0),
        2
    ) AS average_orders_per_customer

FROM LoyaltyPerformance
ORDER BY
    total_sales DESC;
