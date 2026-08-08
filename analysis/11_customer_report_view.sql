USE CoffeeSales;
GO

/*
===============================================================================
11. CUSTOMER REPORT
===============================================================================

Purpose:
    Build a reusable customer-level analytical view containing customer
    attributes, purchasing behavior, sales metrics, lifecycle information,
    and customer segmentation.

Expected Granularity:
    One row per customer.

Customer Attributes:
    - customer_key
    - customer_id
    - customer_name
    - country
    - city
    - loyalty_card

Lifecycle Metrics:
    - first_order_date
    - last_order_date
    - lifespan_months

Behavior Metrics:
    - total_orders
    - total_quantity
    - total_sales
    - average_order_value
    - average_quantity_per_order

Segmentation:
    - spending_segment
    - spending_quartile
    - spending_quartile_label
    - frequency_segment
    - customer_value_segment
===============================================================================
*/

CREATE OR ALTER VIEW gold.report_customers AS

WITH CustomerBase AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.customer_name,
        c.country,
        c.city,
        c.loyalty_card,

        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date,

        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.quantity) AS total_quantity,
        SUM(o.sales) AS total_sales

    FROM gold.fact_orders AS o

    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key

    GROUP BY
        c.customer_key,
        c.customer_id,
        c.customer_name,
        c.country,
        c.city,
        c.loyalty_card
),

CustomerMetrics AS (
    SELECT
        customer_key,
        customer_id,
        customer_name,
        country,
        city,
        loyalty_card,

        first_order_date,
        last_order_date,

        DATEDIFF(
            MONTH,
            first_order_date,
            last_order_date
        ) AS lifespan_months,

        total_orders,
        total_quantity,
        total_sales,

        -- Average amount spent per order.
        ROUND(
            1.0 * total_sales
            / NULLIF(total_orders, 0),
            2
        ) AS average_order_value,

        -- Average number of items purchased per order.
        ROUND(
            1.0 * total_quantity
            / NULLIF(total_orders, 0),
            2
        ) AS average_quantity_per_order

    FROM CustomerBase
),

CustomerQuartiles AS (
    SELECT
        customer_key,
        customer_id,
        customer_name,
        country,
        city,
        loyalty_card,

        first_order_date,
        last_order_date,
        lifespan_months,

        total_orders,
        total_quantity,
        total_sales,
        average_order_value,
        average_quantity_per_order,

        -- Quartile 1 represents the top 25% of customers by spending.
        NTILE(4) OVER (
            ORDER BY total_sales DESC
        ) AS spending_quartile

    FROM CustomerMetrics
)

SELECT
    -- Customer identifiers
    customer_key,
    customer_id,
    customer_name,

    -- Customer location
    country,
    city,

    -- Customer lifecycle
    first_order_date,
    last_order_date,
    lifespan_months,

    -- Customer behavior
    total_orders,
    total_quantity,
    total_sales,
    average_order_value,
    average_quantity_per_order,

    -- Spending-only segmentation
    CASE
        WHEN total_sales < 50
            THEN 'Low Value'

        WHEN total_sales BETWEEN 50 AND 150
            THEN 'Medium Value'

        ELSE 'High Value'
    END AS spending_segment,

    -- Relative spending position
    spending_quartile,

    CASE
        WHEN spending_quartile = 1
            THEN 'Top 25%'

        WHEN spending_quartile = 2
            THEN 'Upper-Middle 25%'

        WHEN spending_quartile = 3
            THEN 'Lower-Middle 25%'

        WHEN spending_quartile = 4
            THEN 'Bottom 25%'
    END AS spending_quartile_label,

    -- Purchase-frequency segmentation
    CASE
        WHEN total_orders = 1
            THEN 'One-Time'

        WHEN total_orders BETWEEN 2 AND 3
            THEN 'Occasional'

        WHEN total_orders >= 4
            THEN 'Frequent'

        ELSE 'No Purchase'
    END AS frequency_segment,

    -- Combined spending + frequency segmentation
    CASE
        WHEN total_sales > 150
             AND total_orders >= 4
            THEN 'High Value'

        WHEN total_sales BETWEEN 50 AND 150
             OR total_orders BETWEEN 2 AND 3
            THEN 'Medium Value'

        ELSE 'Low Value'
    END AS customer_value_segment,

    -- Customer attribute
    loyalty_card

FROM CustomerQuartiles;
GO


-- =============================================================================
-- Validation
-- =============================================================================

SELECT *
FROM gold.report_customers;
