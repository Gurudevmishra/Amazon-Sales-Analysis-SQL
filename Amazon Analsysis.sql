
-- AMAZON SALES ANALYSIS PROJECT


USE amazon_sales_project;


SELECT COUNT(*) AS total_rows
FROM amazon_raw;



SELECT *
FROM amazon_raw
LIMIT 10;
-- STEP 4: Check missing Order IDs

SELECT COUNT(*) AS missing_order_ids
FROM amazon_raw
WHERE `Order ID` IS NULL;
-- STEP 5: Check missing values in all columns

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN `Order ID` IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN `Product` IS NULL THEN 1 ELSE 0 END) AS missing_product,
    SUM(CASE WHEN `Quantity Ordered` IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN `Price Each` IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN `Order Date` IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN `Purchase Address` IS NULL THEN 1 ELSE 0 END) AS missing_address
FROM amazon_sales_project.amazon_raw;


SELECT
    `Order ID`,
    `Product`,
    `Quantity Ordered`,
    `Price Each`,
    `Order Date`,
    `Purchase Address`,
    COUNT(*) AS duplicate_count
FROM amazon_sales_project.amazon_raw
GROUP BY
    `Order ID`,
    `Product`,
    `Quantity Ordered`,
    `Price Each`,
    `Order Date`,
    `Purchase Address`
HAVING COUNT(*) > 1;


CREATE TABLE amazon_sales_project.amazon_cleaned
AS
SELECT *
FROM amazon_sales_project.amazon_raw;
-- STEP 8: Check missing and blank Order IDs

SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN `Order ID` IS NULL
                 OR TRIM(`Order ID`) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_order_ids
FROM amazon_sales_project.amazon_cleaned;

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN `Order ID` IS NULL
        OR TRIM(`Order ID`) = ''
        THEN 1 ELSE 0 END) AS missing_order_id,

    SUM(CASE WHEN `Product` IS NULL
        OR TRIM(`Product`) = ''
        THEN 1 ELSE 0 END) AS missing_product,

    SUM(CASE WHEN `Quantity Ordered` IS NULL
        OR TRIM(`Quantity Ordered`) = ''
        THEN 1 ELSE 0 END) AS missing_quantity,

    SUM(CASE WHEN `Price Each` IS NULL
        OR TRIM(`Price Each`) = ''
        THEN 1 ELSE 0 END) AS missing_price,

    SUM(CASE WHEN `Order Date` IS NULL
        OR TRIM(`Order Date`) = ''
        THEN 1 ELSE 0 END) AS missing_date,

    SUM(CASE WHEN `Purchase Address` IS NULL
        OR TRIM(`Purchase Address`) = ''
        THEN 1 ELSE 0 END) AS missing_address

FROM amazon_sales_project.amazon_cleaned;

SELECT
    `Order ID`,
    `Product`,
    `Quantity Ordered`,
    `Price Each`
FROM amazon_sales_project.amazon_cleaned
WHERE
    (
        `Quantity Ordered` IS NOT NULL
        AND TRIM(`Quantity Ordered`) <> ''
        AND TRIM(`Quantity Ordered`) NOT REGEXP '^[0-9]+$'
    )
    OR
    (
        `Price Each` IS NOT NULL
        AND TRIM(`Price Each`) <> ''
        AND TRIM(`Price Each`) NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
    );
    
   

SELECT
    `Order ID`,
    `Product`,
    `Quantity Ordered`,
    `Price Each`
FROM amazon_sales_project.amazon_cleaned
WHERE
    (
        TRIM(`Quantity Ordered`) REGEXP '^[0-9]+$'
        AND CAST(`Quantity Ordered` AS UNSIGNED) = 0
    )
    OR
    (
        TRIM(`Price Each`) REGEXP '^-?[0-9]+(\\.[0-9]+)?$'
        AND CAST(`Price Each` AS DECIMAL(12,2)) <= 0
    );
SELECT
    `Order ID`,
    `Product`,
    `Quantity Ordered`,
    `Price Each`,
    ROUND(`Quantity Ordered` * `Price Each`, 2) AS Sales_Revenue
FROM amazon_sales_project.amazon_cleaned
LIMIT 10;

SELECT
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Sales_Revenue
FROM amazon_sales_project.amazon_cleaned;

SELECT
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    SUM(`Quantity Ordered`) AS Total_Units_Sold,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`), 2
    ) AS Total_Revenue,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`)
        / NULLIF(COUNT(DISTINCT `Order ID`), 0), 2
    ) AS Average_Order_Value
FROM amazon_sales_project.amazon_cleaned;

SELECT
    `Product`,
    SUM(`Quantity Ordered`) AS Total_Units_Sold,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Revenue
FROM amazon_sales_project.amazon_cleaned
WHERE `Product` IS NOT NULL
GROUP BY `Product`
ORDER BY Total_Revenue DESC
LIMIT 10;

SELECT
    `Product`,
    SUM(`Quantity Ordered`) AS Total_Units_Sold,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Revenue
FROM amazon_sales_project.amazon_cleaned
WHERE `Product` IS NOT NULL
GROUP BY `Product`
ORDER BY Total_Units_Sold DESC
LIMIT 10;

SELECT
    `Purchase Address`
FROM amazon_sales_project.amazon_cleaned
WHERE `Purchase Address` IS NOT NULL
LIMIT 10;


SELECT
    `Purchase Address`,
    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(`Purchase Address`, ',', 2),
            ',', -1
        )
    ) AS City
FROM amazon_sales_project.amazon_cleaned
LIMIT 10;


SELECT
    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(`Purchase Address`, ',', 2),
            ',', -1
        )
    ) AS City,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    SUM(`Quantity Ordered`) AS Units_Sold,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Revenue
FROM amazon_sales_project.amazon_cleaned
WHERE `Purchase Address` IS NOT NULL
GROUP BY City
ORDER BY Total_Revenue DESC;


SELECT
    `Order ID`,
    `Order Date`
FROM amazon_sales_project.amazon_cleaned
LIMIT 10;


SELECT
    `Order Date`,
    STR_TO_DATE(
        `Order Date`,
        '%m/%d/%y %H:%i'
    ) AS Converted_Date
FROM amazon_sales_project.amazon_cleaned
LIMIT 10;


SELECT
    `Order Date`,
    COALESCE(
        STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
        STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
    ) AS Converted_Date
FROM amazon_sales_project.amazon_cleaned
LIMIT 10;


SELECT
    DATE_FORMAT(
        COALESCE(
            STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
            STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
        ),
        '%Y-%m'
    ) AS Sales_Month,

    COUNT(DISTINCT `Order ID`) AS Total_Orders,

    SUM(`Quantity Ordered`) AS Units_Sold,

    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Revenue

FROM amazon_sales_project.amazon_cleaned

GROUP BY Sales_Month
ORDER BY Sales_Month;


SELECT
    DATE_FORMAT(
        COALESCE(
            STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
            STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
        ),
        '%Y-%m'
    ) AS Sales_Month,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Revenue
FROM amazon_sales_project.amazon_cleaned
GROUP BY Sales_Month
ORDER BY Total_Revenue DESC;


WITH Monthly_Sales AS (
    SELECT
        DATE_FORMAT(
            COALESCE(
                STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
                STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
            ),
            '%Y-%m'
        ) AS Sales_Month,
        SUM(`Quantity Ordered` * `Price Each`) AS Revenue
    FROM amazon_sales_project.amazon_cleaned
    GROUP BY Sales_Month
),
Sales_Growth AS (
    SELECT
        Sales_Month,
        Revenue,
        LAG(Revenue) OVER (
            ORDER BY Sales_Month
        ) AS Previous_Month_Revenue
    FROM Monthly_Sales
    WHERE Sales_Month IS NOT NULL
)
SELECT
    Sales_Month,
    ROUND(Revenue, 2) AS Total_Revenue,
    ROUND(Previous_Month_Revenue, 2) AS Previous_Month_Revenue,
    ROUND(
        (Revenue - Previous_Month_Revenue)
        / NULLIF(Previous_Month_Revenue, 0) * 100,
        2
    ) AS MoM_Growth_Percentage
FROM Sales_Growth
ORDER BY Sales_Month;


SELECT
    COUNT(*) AS Total_Rows,
    SUM(
        CASE
            WHEN COALESCE(
                STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
                STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
            ) IS NULL THEN 1
            ELSE 0
        END
    ) AS Invalid_Dates
FROM amazon_sales_project.amazon_cleaned;


SELECT
    HOUR(
        COALESCE(
            STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
            STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
        )
    ) AS Sales_Hour,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Revenue
FROM amazon_sales_project.amazon_cleaned
GROUP BY Sales_Hour
ORDER BY Total_Orders DESC;



SELECT
    DAYNAME(
        COALESCE(
            STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
            STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
        )
    ) AS Sales_Day,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    SUM(`Quantity Ordered`) AS Units_Sold,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Revenue
FROM amazon_sales_project.amazon_cleaned
WHERE COALESCE(
    STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
    STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
) IS NOT NULL
GROUP BY Sales_Day
ORDER BY Total_Revenue DESC;


SELECT
    CASE
        WHEN DAYOFWEEK(
            COALESCE(
                STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
                STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
            )
        ) IN (1, 7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    SUM(`Quantity Ordered`) AS Units_Sold,
    ROUND(
        SUM(`Quantity Ordered` * `Price Each`),
        2
    ) AS Total_Revenue
FROM amazon_sales_project.amazon_cleaned
WHERE COALESCE(
    STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
    STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
) IS NOT NULL
GROUP BY Day_Type
ORDER BY Total_Revenue DESC;


CREATE OR REPLACE VIEW
amazon_sales_project.amazon_sales_final AS

SELECT
    `Order ID`,
    `Product`,
    `Quantity Ordered`,
    `Price Each`,
    `Order Date`,
    `Purchase Address`,

    ROUND(
        `Quantity Ordered` * `Price Each`,
        2
    ) AS Sales_Revenue,

    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(`Purchase Address`, ',', 2),
            ',', -1
        )
    ) AS City,

    COALESCE(
        STR_TO_DATE(`Order Date`, '%m/%d/%y %H:%i'),
        STR_TO_DATE(`Order Date`, '%m-%d-%Y %H:%i')
    ) AS Converted_Date

FROM amazon_sales_project.amazon_cleaned;

SELECT *
FROM amazon_sales_project.amazon_sales_final
LIMIT 10;


SELECT
    COUNT(*) AS Total_Records,

    COUNT(DISTINCT `Order ID`) AS Unique_Orders,

    SUM(
        CASE
            WHEN `Order ID` IS NULL
            THEN 1 ELSE 0
        END
    ) AS Missing_Order_IDs,

    SUM(
        CASE
            WHEN `Product` IS NULL
                 OR TRIM(`Product`) = ''
            THEN 1 ELSE 0
        END
    ) AS Missing_Products,

    SUM(
        CASE
            WHEN `Quantity Ordered` <= 0
                 OR `Price Each` <= 0
            THEN 1 ELSE 0
        END
    ) AS Invalid_Sales,

    SUM(
        CASE
            WHEN Converted_Date IS NULL
            THEN 1 ELSE 0
        END
    ) AS Invalid_Dates

FROM amazon_sales_project.amazon_sales_final;


SELECT
    `Order ID`,
    `Product`,
    `Quantity Ordered`,
    `Price Each`,
    `Order Date`,
    `Purchase Address`,
    COUNT(*) AS Duplicate_Count
FROM amazon_sales_project.amazon_cleaned
GROUP BY
    `Order ID`,
    `Product`,
    `Quantity Ordered`,
    `Price Each`,
    `Order Date`,
    `Purchase Address`
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;


SELECT
    `Product`,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    SUM(`Quantity Ordered`) AS Units_Sold,
    ROUND(
        SUM(Sales_Revenue), 2
    ) AS Total_Revenue,
    ROUND(
        SUM(Sales_Revenue) /
        NULLIF(SUM(`Quantity Ordered`), 0),
        2
    ) AS Average_Selling_Price,
    ROUND(
        SUM(Sales_Revenue) * 100.0 /
        NULLIF(
            (SELECT SUM(Sales_Revenue)
             FROM amazon_sales_project.amazon_sales_final
             WHERE `Product` IS NOT NULL
               AND TRIM(`Product`) <> ''),
            0
        ),
        2
    ) AS Revenue_Contribution_Percent
FROM amazon_sales_project.amazon_sales_final
WHERE `Product` IS NOT NULL
  AND TRIM(`Product`) <> ''
GROUP BY `Product`
ORDER BY Total_Revenue DESC;


SELECT
    ROUND(SUM(Sales_Revenue), 2) AS Total_Revenue,

    COUNT(DISTINCT `Order ID`) AS Total_Orders,

    SUM(`Quantity Ordered`) AS Total_Units_Sold,

    ROUND(
        SUM(Sales_Revenue) /
        NULLIF(COUNT(DISTINCT `Order ID`), 0),
        2
    ) AS Average_Order_Value,
    
    

    COUNT(DISTINCT `Product`) AS Total_Products,

    COUNT(DISTINCT City) AS Total_Cities

FROM amazon_sales_project.amazon_sales_final;


SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Sales_Revenue), 2) AS Total_Revenue,
    SUM(CASE WHEN Converted_Date IS NULL THEN 1 ELSE 0 END) AS Invalid_Dates
FROM amazon_sales_project.amazon_sales_final;





		
