USE CoffeeSales;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

        DECLARE @start_time DATETIME, 
                @end_time DATETIME,
                @batch_start_time DATETIME, 
                @batch_end_time DATETIME;


    BEGIN TRY
        PRINT '==============================================================================================='
        PRINT 'Loading Silver Layer tables';
        PRINT '==============================================================================================='

        SET @start_time = GETDATE();
        SET @batch_start_time = GETDATE();
    
        PRINT 'Loading silver.customers table';
        TRUNCATE TABLE silver.customers;

        INSERT INTO silver.customers (
            customer_id, customer_name, email, phone_number,
            address, city, country, postcode, loyalty_card
        )
        SELECT
            TRIM(customer_id),
            TRIM(customer_name),
            LOWER(TRIM(email)),
            TRIM(phone_number),
            TRIM(address),
            TRIM(city),
            TRIM(country),
            TRIM(postcode),
            TRIM(loyalty_card)
        FROM bronze.customers;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT 'Loading silver.products table';
        TRUNCATE TABLE silver.products;

        INSERT INTO silver.products (
            product_id, coffee_type, roast_type, size,
            unit_price, price_per_100g, profit
        )
        SELECT
            TRIM(product_id),
            TRIM(coffee_type),
            TRIM(roast_type),
            size,
            unit_price,
            price_per_100g,
            profit
        FROM bronze.products;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------------------------------------------';


        SET @start_time = GETDATE();
        PRINT 'Loading silver.orders table';

        TRUNCATE TABLE silver.orders;

        INSERT INTO silver.orders (
            order_id, order_date, customer_id, product_id,
            quantity, unit_price, sales
        )
        SELECT
            TRIM(o.order_id),
            o.order_date,
            TRIM(o.customer_id),
            TRIM(o.product_id),
            o.quantity,
            p.unit_price,
            o.quantity * p.unit_price
        FROM bronze.orders o
        LEFT JOIN bronze.products p
            ON o.product_id = p.product_id;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------------------------------------------';


        SET @batch_end_time = GETDATE();

        PRINT '=================================================================================================';
        PRINT 'Loading Silver Layer has been successfully completed.';
        PRINT 'Total Loading Time = ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
        PRINT '=================================================================================================';


    END TRY
    BEGIN CATCH
        PRINT 'ERROR OCCURRED WHILE LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
    END CATCH
END;
GO

-- Run manually when needed:
-- EXEC silver.load_silver;


