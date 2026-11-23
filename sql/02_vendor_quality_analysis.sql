USE vendor_performance_db;

-- Vendor-wise quality performance

SELECT
    Vendor_ID,
    Vendor_Name,

    COUNT(*) AS total_orders,

    SUM(Quantity_Delivered) AS total_quantity_delivered,

    SUM(Defective_Quantity) AS total_defective_quantity,

    SUM(Accepted_Quantity) AS total_accepted_quantity,

    ROUND(
        SUM(Accepted_Quantity) * 100.0 /
        NULLIF(SUM(Quantity_Delivered), 0),
        2
    ) AS quality_rate,

    ROUND(
        SUM(Defective_Quantity) * 100.0 /
        NULLIF(SUM(Quantity_Delivered), 0),
        2
    ) AS defect_rate

FROM purchase_orders

GROUP BY Vendor_ID, Vendor_Name

ORDER BY quality_rate DESC;