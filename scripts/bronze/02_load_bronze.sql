/*
===============================================================================
BRONZE LAYER LOAD PROCEDURE
===============================================================================

Author: Kevin Garcia

Description:
    Loads raw CSV files into Bronze tables.

Process:
    1. Truncate existing Bronze tables.
    2. Load customers.csv
    3. Load orders.csv
    4. Load products.csv
    5. Log load duration.
    6. Handle errors using TRY/CATCH.

Purpose:
    Bronze layer stores raw source data without transformations.
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME, 
            @end_time DATETIME,
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

    BEGIN TRY
        PRINT '=================================================================================================';
        PRINT 'Loading the Bronze Layer';
        PRINT '=================================================================================================';

        SET @batch_start_time = GETDATE();

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.customers';
        TRUNCATE TABLE bronze.customers;

        PRINT '>> Inserting Data Into: bronze.customers';
        BULK INSERT bronze.customers
        FROM 'C:\CoffeeSales\customers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.orders';
        TRUNCATE TABLE bronze.orders;

        PRINT '>> Inserting Data Into: bronze.orders';
        BULK INSERT bronze.orders
        FROM 'C:\CoffeeSales\orders.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '-------------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.products';
        TRUNCATE TABLE bronze.products;

        PRINT '>> Inserting Data Into: bronze.products';
        BULK INSERT bronze.products
        FROM 'C:\CoffeeSales\products.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';

        SET @batch_end_time = GETDATE();

        PRINT '=================================================================================================';
        PRINT 'Loading Bronze Layer has been successfully completed.';
        PRINT 'Total Loading Time = ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
        PRINT '=================================================================================================';

    END TRY
    BEGIN CATCH
        PRINT '===================================================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT '===================================================================================';
    END CATCH
END;
GO

-- Run manually when needed:
-- EXEC bronze.load_bronze;
