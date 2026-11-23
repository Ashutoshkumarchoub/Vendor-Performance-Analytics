USE vendor_performance_db;

-- Vendor-wise procurement cost analysis

SELECT
    Vendor_ID,
    Vendor_Name,
    Product_Category,

    COUNT(*) AS total_orders,

    SUM(Quantity_Ordered) AS total_quantity_ordered,

    ROUND(SUM(Total_Order_Value), 2) AS total_procurement_value,

    ROUND(
        SUM(Total_Order_Value) /
        NULLIF(SUM(Quantity_Ordered), 0),
        2
    ) AS weighted_avg_unit_cost,

    DENSE_RANK() OVER (
        PARTITION BY Product_Category
        ORDER BY
            SUM(Total_Order_Value) /
            NULLIF(SUM(Quantity_Ordered), 0)
    ) AS cost_rank_in_category

FROM purchase_orders

GROUP BY
    Vendor_ID,
    Vendor_Name,
    Product_Category

ORDER BY
    Product_Category,
    cost_rank_in_category;