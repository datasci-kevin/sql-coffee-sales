USE CoffeeSales;
GO

/*
===============================================================================
10. DATA SEGMENTATION
===============================================================================

Purpose:
    Segment customers, products, and orders into meaningful business groups
    based on spending, purchase frequency, sales performance, profitability,
    order value, loyalty status, and relative customer spending.

Business Questions:
    1. How can customers be segmented by total spending?
    2. How can customers be segmented by purchase frequency?
    3. How can customers be segmented based on both spending and order count?
    4. Which customers qualify as VIP customers?
    5. How can products be segmented by total sales performance?
    6. How can products be segmented by total profit performance?
    7. How can orders be grouped into low-, medium-, and high-value orders?
    8. How do loyalty and non-loyalty customers distribute across spending segments?
    9. How can customers be divided into quartiles based on total spending?
===============================================================================
*/


-- =============================================================================
-- Question 1:
-- How can customers be segmented by total spending?
-- =============================================================================

/*
Spending thresholds were selected after exploring
the customer sales distribution.

Minimum = $2.69
Average = $49.44
Maximum = $317.11
*/

WITH CustomerSales AS (
    SELECT
        c.customer_id,
        SUM(o.sales) AS customer_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY
        c.customer_id
),

CustomerSegments AS (
    SELECT
        customer_id,
        customer_sales,

        CASE
            WHEN customer_sales < 50
                THEN 'Low Value'

            WHEN customer_sales BETWEEN 50 AND 150
                THEN 'Medium Value'

            ELSE 'High Value'
        END AS spending_segment

    FROM CustomerSales
),

CustomerCounts AS (
    SELECT
        spending_segment,
        COUNT(*) AS total_customers,
        SUM(customer_sales) AS total_sales,
        AVG(customer_sales) AS average_sales
    FROM CustomerSegments
    GROUP BY
        spending_segment
)

SELECT
    spending_segment,
    total_customers,
    total_sales,
    ROUND(average_sales, 2) AS average_sales,

    ROUND(
        100.0 * total_customers
        / SUM(total_customers) OVER (),
        2
    ) AS customer_percentage

FROM CustomerCounts
ORDER BY
    average_sales DESC;



-- =============================================================================
-- Question 2:
-- How can customers be segmented by purchase frequency?
-- =============================================================================

WITH CustomerOrders AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.order_id) AS number_of_orders
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY
        c.customer_id
)

SELECT
    customer_id,
    number_of_orders,

    CASE
        WHEN number_of_orders = 1
            THEN 'One-Time'

        WHEN number_of_orders BETWEEN 2 AND 3
            THEN 'Occasional'

        WHEN number_of_orders >= 4
            THEN 'Frequent'

        ELSE 'No Purchase'
    END AS frequency_segment

FROM CustomerOrders
ORDER BY
    number_of_orders DESC;



-- =============================================================================
-- Question 3:
-- How can customers be segmented based on both spending and order count?
-- =============================================================================

WITH CustomerSummary AS (
    SELECT
        c.customer_id,
        SUM(o.sales) AS total_sales,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY
        c.customer_id
),

CustomerSegments AS (
    SELECT
        customer_id,
        total_sales,
        total_orders,

        CASE
            -- Customers must demonstrate both high spending
            -- and frequent purchasing behavior.
            WHEN total_sales > 150
                 AND total_orders >= 4
                THEN 'High Value'

            -- Customers demonstrating moderate spending
            -- or recurring purchase behavior.
            WHEN total_sales BETWEEN 50 AND 150
                 OR total_orders BETWEEN 2 AND 3
                THEN 'Medium Value'

            ELSE 'Low Value'
        END AS customer_value_segment

    FROM CustomerSummary
)

SELECT
    customer_id,
    total_sales,
    total_orders,
    customer_value_segment

FROM CustomerSegments
ORDER BY
    total_sales DESC;



-- =============================================================================
-- Question 4:
-- Which customers qualify as VIP customers?
-- =============================================================================

WITH CustomerSummary AS (
    SELECT
        c.customer_id,
        SUM(o.sales) AS total_sales,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY
        c.customer_id
),

CustomerSegments AS (
    SELECT
        customer_id,
        total_sales,
        total_orders,

        CASE
            WHEN total_sales > 150
                 AND total_orders >= 4
                THEN 'High Value'

            WHEN total_sales BETWEEN 50 AND 150
                 OR total_orders BETWEEN 2 AND 3
                THEN 'Medium Value'

            ELSE 'Low Value'
        END AS customer_value_segment

    FROM CustomerSummary
)

SELECT
    customer_id,
    total_sales,
    total_orders

FROM CustomerSegments
WHERE
    customer_value_segment = 'High Value'

ORDER BY
    total_sales DESC;



-- =============================================================================
-- Question 5:
-- How can products be segmented by total sales performance?
-- =============================================================================

/*
Thresholds were selected after reviewing the approximate
product sales range in the dataset.

Low Value     < $500
Medium Value  $500 - $1,500
High Value    > $1,500
*/

WITH ProductSales AS (
    SELECT
        p.product_id,
        SUM(o.sales) AS product_sales
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY
        p.product_id
)

SELECT
    product_id,
    product_sales,

    CASE
        WHEN product_sales < 500
            THEN 'Low Value'

        WHEN product_sales BETWEEN 500 AND 1500
            THEN 'Medium Value'

        ELSE 'High Value'
    END AS product_segment

FROM ProductSales
ORDER BY
    product_sales DESC;



-- =============================================================================
-- Question 6:
-- How can products be segmented by total profit performance?
-- =============================================================================

WITH ProductProfits AS (
    SELECT
        p.product_id,

        -- Profit is stored per unit, so total product profit
        -- is quantity sold multiplied by profit per unit.
        SUM(o.quantity * p.profit) AS total_profit

    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key

    GROUP BY
        p.product_id
)

SELECT
    product_id,
    total_profit,

    CASE
        WHEN total_profit < 50
            THEN 'Low Profit'

        WHEN total_profit BETWEEN 50 AND 150
            THEN 'Medium Profit'

        ELSE 'High Profit'
    END AS profit_segment

FROM ProductProfits
ORDER BY
    total_profit DESC;



-- =============================================================================
-- Question 7:
-- How can orders be grouped into low-, medium-, and high-value orders?
-- =============================================================================

WITH OrderSales AS (
    SELECT
        order_id,

        -- fact_orders contains order lines, so sales must first
        -- be aggregated to one row per complete order.
        SUM(sales) AS order_value

    FROM gold.fact_orders
    GROUP BY
        order_id
),

OrderSegments AS (
    SELECT
        order_id,
        order_value,

        CASE
            WHEN order_value < 50
                THEN 'Low Value Order'

            WHEN order_value BETWEEN 50 AND 150
                THEN 'Medium Value Order'

            ELSE 'High Value Order'
        END AS order_value_segment

    FROM OrderSales
)

SELECT
    order_value_segment,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_value), 2) AS average_order_value,
    SUM(order_value) AS total_sales

FROM OrderSegments
GROUP BY
    order_value_segment

ORDER BY
    average_order_value DESC;

-- =============================================================================
-- Question 8:
-- How do loyalty and non-loyalty customers distribute across spending segments?
-- =============================================================================

WITH CustomerSummary AS (
    SELECT
        c.customer_id,
        c.loyalty_card,
        SUM(o.sales) AS total_sales

    FROM gold.fact_orders AS o

    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key

    GROUP BY
        c.customer_id,
        c.loyalty_card
),

CustomerSegments AS (
    SELECT
        customer_id,
        loyalty_card,
        total_sales,

        CASE
            WHEN total_sales < 50
                THEN 'Low Value'

            WHEN total_sales BETWEEN 50 AND 150
                THEN 'Medium Value'

            ELSE 'High Value'
        END AS spending_segment

    FROM CustomerSummary
)

SELECT
    loyalty_card,
    spending_segment,
    COUNT(*) AS total_customers,

    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (
            PARTITION BY loyalty_card
        ),
        2
    ) AS percentage_within_loyalty_group

FROM CustomerSegments

GROUP BY
    loyalty_card,
    spending_segment

ORDER BY
    loyalty_card,
    total_customers DESC;



-- =============================================================================
-- Question 9:
-- How can customers be divided into quartiles based on total spending?
-- =============================================================================

WITH CustomerSales AS (
    SELECT
        c.customer_id,
        SUM(o.sales) AS total_spending

    FROM gold.fact_orders AS o

    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key

    GROUP BY
        c.customer_id
),

CustomerQuartiles AS (
    SELECT
        customer_id,
        total_spending,

        NTILE(4) OVER (
            ORDER BY total_spending DESC
        ) AS spending_quartile

    FROM CustomerSales
)

SELECT
    customer_id,
    total_spending,
    spending_quartile,

    CASE
        WHEN spending_quartile = 1 THEN 'Top 25%'
        WHEN spending_quartile = 2 THEN 'Upper-Middle 25%'
        WHEN spending_quartile = 3 THEN 'Lower-Middle 25%'
        WHEN spending_quartile = 4 THEN 'Bottom 25%'
    END AS spending_segment

FROM CustomerQuartiles

ORDER BY
    total_spending DESC;
