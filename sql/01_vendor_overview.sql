USE vendor_performance_db;

-- 1. Total vendors
SELECT COUNT(*) AS total_vendors
FROM vendors;

-- 2. Total purchase orders
SELECT COUNT(*) AS total_purchase_orders
FROM purchase_orders;

-- 3. Total procurement spending
SELECT ROUND(SUM(Total_Order_Value), 2) AS total_procurement_value
FROM purchase_orders;

-- 4. Average purchase order value
SELECT ROUND(AVG(Total_Order_Value), 2) AS average_order_value
FROM purchase_orders;

-- 5. Overall delivery status
SELECT
    Delivery_Status,
    COUNT(*) AS total_orders
FROM purchase_orders
GROUP BY Delivery_Status
ORDER BY total_orders DESC;

-- Vendor-wise delivery performance

SELECT
    Vendor_ID,
    Vendor_Name,

    COUNT(*) AS total_orders,

    COUNT(Actual_Delivery_Date) AS valid_deliveries,

    SUM(CASE
        WHEN Delivery_Status IN ('Early', 'On-Time')
        THEN 1 ELSE 0
    END) AS successful_deliveries,

    SUM(CASE
        WHEN Delivery_Status = 'Late'
        THEN 1 ELSE 0
    END) AS late_deliveries,

    ROUND(
        SUM(CASE
            WHEN Delivery_Status IN ('Early', 'On-Time')
            THEN 1 ELSE 0
        END) * 100.0 /
        COUNT(Actual_Delivery_Date), 2
    ) AS on_time_delivery_rate,

    ROUND(AVG(Delivery_Delay_Days), 2) AS average_delay_days

FROM purchase_orders

GROUP BY Vendor_ID, Vendor_Name

ORDER BY on_time_delivery_rate DESC;