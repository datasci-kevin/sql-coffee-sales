/*
===============================================================================
DIMENSION EXPLORATION
===============================================================================
Purpose:
    Explore categorical fields available in the Gold Layer.
===============================================================================
*/

-- Explore countries
SELECT DISTINCT
    country
FROM gold.dim_customers
ORDER BY country;

-- Explore loyalty card values
SELECT DISTINCT
    loyalty_card
FROM gold.dim_customers
ORDER BY loyalty_card;

-- Explore coffee types
SELECT DISTINCT
    coffee_type
FROM gold.dim_products
ORDER BY coffee_type;

-- Explore roast types
SELECT DISTINCT
    roast_type
FROM gold.dim_products
ORDER BY roast_type;

-- Explore product sizes
SELECT DISTINCT
    size
FROM gold.dim_products
ORDER BY size;
