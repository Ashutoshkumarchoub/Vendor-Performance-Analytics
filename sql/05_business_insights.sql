
USE vendor_performance_db;

-- 1. Overall delivery performance
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Delivery_Status = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    SUM(CASE WHEN Delivery_Status IN ('Early', 'On-Time') THEN 1 ELSE 0 END) AS successful_orders,
    ROUND(
        SUM(CASE WHEN Delivery_Status IN ('Early', 'On-Time') THEN 1 ELSE 0 END)
        * 100.0 / COUNT(Actual_Delivery_Date),
        2
    ) AS successful_delivery_rate
FROM purchase_orders;

-- 2. Overall product quality
SELECT
    ROUND(SUM(Accepted_Quantity) * 100.0 /
    NULLIF(SUM(Quantity_Delivered), 0), 2) AS overall_quality_rate,
    SUM(Defective_Quantity) AS total_defective_quantity
FROM purchase_orders;

-- 3. Monthly procurement trend
SELECT
    Order_Year,
    Order_Month,
    Month_Name,
    COUNT(*) AS total_orders,
    ROUND(SUM(Total_Order_Value), 2) AS monthly_procurement_value
FROM purchase_orders
GROUP BY Order_Year, Order_Month, Month_Name
ORDER BY Order_Year, Order_Month;

-- 4. Vendor classification summary
WITH score_data AS (
    SELECT
        Vendor_ID,
        ROUND(
            delivery_score * 0.40 +
            quality_score * 0.35 +
            cost_score * 0.25,
            2
        ) AS overall_score
    FROM (
        SELECT
            d.Vendor_ID,
            d.delivery_score,
            q.quality_score,
            c.cost_score
        FROM (
            SELECT
                Vendor_ID,
                SUM(CASE WHEN Delivery_Status IN ('Early', 'On-Time')
                    THEN 1 ELSE 0 END) * 100.0 /
                NULLIF(COUNT(Actual_Delivery_Date), 0) AS delivery_score
            FROM purchase_orders
            GROUP BY Vendor_ID
        ) d
        JOIN (
            SELECT
                Vendor_ID,
                SUM(Accepted_Quantity) * 100.0 /
                NULLIF(SUM(Quantity_Delivered), 0) AS quality_score
            FROM purchase_orders
            GROUP BY Vendor_ID
        ) q ON d.Vendor_ID = q.Vendor_ID
        JOIN (
            SELECT Vendor_ID, AVG(category_score) AS cost_score
            FROM (
                SELECT
                    Vendor_ID,
                    Product_Category,
                    CASE
                        WHEN max_cost = min_cost THEN 100
                        ELSE (max_cost - avg_cost) * 100.0 /
                             (max_cost - min_cost)
                    END AS category_score
                FROM (
                    SELECT
                        Vendor_ID,
                        Product_Category,
                        avg_cost,
                        MIN(avg_cost) OVER (PARTITION BY Product_Category) AS min_cost,
                        MAX(avg_cost) OVER (PARTITION BY Product_Category) AS max_cost
                    FROM (
                        SELECT
                            Vendor_ID,
                            Product_Category,
                            SUM(Total_Order_Value) /
                            NULLIF(SUM(Quantity_Ordered), 0) AS avg_cost
                        FROM purchase_orders
                        GROUP BY Vendor_ID, Product_Category
                    ) x
                ) y
            ) z
            GROUP BY Vendor_ID
        ) c ON d.Vendor_ID = c.Vendor_ID
    ) final_scores
)
SELECT
    CASE
        WHEN overall_score >= 85 THEN 'Excellent'
        WHEN overall_score >= 70 THEN 'Good'
        WHEN overall_score >= 55 THEN 'Average'
        WHEN overall_score >= 40 THEN 'Needs Improvement'
        ELSE 'High Risk'
    END AS vendor_category,
    COUNT(*) AS vendor_count
FROM score_data
GROUP BY vendor_category
ORDER BY vendor_count DESC;
