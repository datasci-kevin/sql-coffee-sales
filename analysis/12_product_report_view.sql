USE CoffeeSales;
GO

/*
===============================================================================
12. PRODUCT REPORT
===============================================================================

Purpose:
    Build a reusable product-level analytical view containing
    product information, sales metrics, profitability,
    purchasing behavior, and performance segmentation.

Expected Granularity:
    One row per product.

Product Attributes:
    - product_key
    - product_id
    - coffee_type
    - roast_type
    - size
    - size_category
    - unit_price
    - price_per_100g
    - profit_per_unit

Performance Metrics:
    - total_orders
    - total_quantity
    - total_sales
    - total_profit

Derived Metrics:
    - average_order_value
    - average_quantity_per_order
    - profit_margin_percentage

Segmentation:
    - sales_segment
    - profit_segment
    - sales_quartile
    - sales_quartile_label
===============================================================================
*/

CREATE OR ALTER VIEW gold.report_products
AS

WITH ProductBase AS
(
    SELECT
        p.product_key,
        p.product_id,
        p.coffee_type,
        p.roast_type,
        p.size,
        p.size_category,
        p.unit_price,
        p.price_per_100g,
        p.profit AS profit_per_unit,

        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.quantity) AS total_quantity,
        SUM(o.sales) AS total_sales,

        SUM(o.quantity * p.profit) AS total_profit

    FROM gold.fact_orders AS o

    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key

    GROUP BY

        p.product_key,
        p.product_id,
        p.coffee_type,
        p.roast_type,
        p.size,
        p.size_category,
        p.unit_price,
        p.price_per_100g,
        p.profit
),

ProductMetrics AS
(
    SELECT

        product_key,
        product_id,
        coffee_type,
        roast_type,
        size,
        size_category,
        unit_price,
        price_per_100g,
        profit_per_unit,

        total_orders,
        total_quantity,
        total_sales,
        total_profit,

        ROUND(
            total_sales /
            NULLIF(total_orders,0),
            2
        ) AS average_order_value,

        ROUND(
            1.0 * total_quantity /
            NULLIF(total_orders,0),
            2
        ) AS average_quantity_per_order,

        ROUND(
            100.0 * total_profit /
            NULLIF(total_sales,0),
            2
        ) AS profit_margin_percentage

    FROM ProductBase
),

ProductQuartiles AS
(
    SELECT
        *,

        NTILE(4) OVER(
            ORDER BY total_sales DESC
        ) AS sales_quartile

    FROM ProductMetrics
)

SELECT

    ----------------------------------------------------------
    -- Product Attributes
    ----------------------------------------------------------

    product_key,
    product_id,
    coffee_type,
    roast_type,
    size,
    size_category,

    unit_price,
    price_per_100g,
    profit_per_unit,

    ----------------------------------------------------------
    -- Sales Metrics
    ----------------------------------------------------------

    total_orders,
    total_quantity,
    total_sales,
    total_profit,

    average_order_value,
    average_quantity_per_order,
    profit_margin_percentage,

    ----------------------------------------------------------
    -- Sales Segmentation
    ----------------------------------------------------------

    CASE

        WHEN total_sales < 500
            THEN 'Low Sales'

        WHEN total_sales BETWEEN 500 AND 1500
            THEN 'Medium Sales'

        ELSE 'High Sales'

    END AS sales_segment,

    ----------------------------------------------------------
    -- Profit Segmentation
    ----------------------------------------------------------

    CASE

        WHEN total_profit < 50
            THEN 'Low Profit'

        WHEN total_profit BETWEEN 50 AND 150
            THEN 'Medium Profit'

        ELSE 'High Profit'

    END AS profit_segment,

    ----------------------------------------------------------
    -- Quartiles
    ----------------------------------------------------------

    sales_quartile,

    CASE

        WHEN sales_quartile = 1
            THEN 'Top 25%'

        WHEN sales_quartile = 2
            THEN 'Upper-Middle 25%'

        WHEN sales_quartile = 3
            THEN 'Lower-Middle 25%'

        ELSE 'Bottom 25%'

    END AS sales_quartile_label

FROM ProductQuartiles;
GO


--------------------------------------------------------------
-- Validation
--------------------------------------------------------------

SELECT *
FROM gold.report_products;
