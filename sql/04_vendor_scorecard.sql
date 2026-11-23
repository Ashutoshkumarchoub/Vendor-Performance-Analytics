
USE vendor_performance_db;

-- Final Vendor Performance Scorecard

WITH delivery_metrics AS (
    SELECT
        Vendor_ID,
        Vendor_Name,
        COUNT(Actual_Delivery_Date) AS valid_deliveries,
        SUM(CASE
            WHEN Delivery_Status IN ('Early', 'On-Time') THEN 1
            ELSE 0
        END) AS successful_deliveries,
        ROUND(
            SUM(CASE
                WHEN Delivery_Status IN ('Early', 'On-Time') THEN 1
                ELSE 0
            END) * 100.0 / NULLIF(COUNT(Actual_Delivery_Date), 0),
            2
        ) AS delivery_score
    FROM purchase_orders
    GROUP BY Vendor_ID, Vendor_Name
),

quality_metrics AS (
    SELECT
        Vendor_ID,
        ROUND(
            SUM(Accepted_Quantity) * 100.0 /
            NULLIF(SUM(Quantity_Delivered), 0),
            2
        ) AS quality_score
    FROM purchase_orders
    GROUP BY Vendor_ID
),

vendor_category_cost AS (
    SELECT
        Vendor_ID,
        Product_Category,
        SUM(Total_Order_Value) /
        NULLIF(SUM(Quantity_Ordered), 0) AS avg_unit_cost
    FROM purchase_orders
    GROUP BY Vendor_ID, Product_Category
),

category_cost_ranges AS (
    SELECT
        Vendor_ID,
        Product_Category,
        avg_unit_cost,
        MIN(avg_unit_cost) OVER (
            PARTITION BY Product_Category
        ) AS min_category_cost,
        MAX(avg_unit_cost) OVER (
            PARTITION BY Product_Category
        ) AS max_category_cost
    FROM vendor_category_cost
),

cost_scores AS (
    SELECT
        Vendor_ID,
        ROUND(
            AVG(
                CASE
                    WHEN max_category_cost = min_category_cost THEN 100
                    ELSE
                        (max_category_cost - avg_unit_cost) * 100.0 /
                        (max_category_cost - min_category_cost)
                END
            ),
            2
        ) AS cost_score
    FROM category_cost_ranges
    GROUP BY Vendor_ID
)

SELECT
    d.Vendor_ID,
    d.Vendor_Name,
    d.valid_deliveries,
    d.successful_deliveries,
    d.delivery_score,
    q.quality_score,
    c.cost_score,

    ROUND(
        d.delivery_score * 0.40 +
        q.quality_score * 0.35 +
        c.cost_score * 0.25,
        2
    ) AS overall_vendor_score,

    CASE
        WHEN d.delivery_score * 0.40 +
             q.quality_score * 0.35 +
             c.cost_score * 0.25 >= 85
            THEN 'Excellent'

        WHEN d.delivery_score * 0.40 +
             q.quality_score * 0.35 +
             c.cost_score * 0.25 >= 70
            THEN 'Good'

        WHEN d.delivery_score * 0.40 +
             q.quality_score * 0.35 +
             c.cost_score * 0.25 >= 55
            THEN 'Average'

        WHEN d.delivery_score * 0.40 +
             q.quality_score * 0.35 +
             c.cost_score * 0.25 >= 40
            THEN 'Needs Improvement'

        ELSE 'High Risk'
    END AS vendor_category

FROM delivery_metrics d
JOIN quality_metrics q
    ON d.Vendor_ID = q.Vendor_ID
JOIN cost_scores c
    ON d.Vendor_ID = c.Vendor_ID

ORDER BY overall_vendor_score DESC;