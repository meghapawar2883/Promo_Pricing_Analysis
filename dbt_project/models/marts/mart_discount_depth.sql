WITH txn_with_discount_band AS (
    SELECT
        t.PRODUCT_ID,
        t.STORE_ID,
        t.WEEK_NO,
        t.SALES_VALUE,
        t.QUANTITY,
        t.TOTAL_DISCOUNT,
        t.GROSS_PRICE,
        CASE
            WHEN t.GROSS_PRICE > 0 THEN ROUND(t.TOTAL_DISCOUNT / t.GROSS_PRICE * 100, 0)
            ELSE 0
        END AS DISCOUNT_PCT,
        CASE
            WHEN t.TOTAL_DISCOUNT = 0 THEN '0% (No Discount)'
            WHEN t.GROSS_PRICE > 0 AND (t.TOTAL_DISCOUNT / t.GROSS_PRICE * 100) <= 5 THEN '1-5%'
            WHEN t.GROSS_PRICE > 0 AND (t.TOTAL_DISCOUNT / t.GROSS_PRICE * 100) <= 10 THEN '6-10%'
            WHEN t.GROSS_PRICE > 0 AND (t.TOTAL_DISCOUNT / t.GROSS_PRICE * 100) <= 15 THEN '11-15%'
            WHEN t.GROSS_PRICE > 0 AND (t.TOTAL_DISCOUNT / t.GROSS_PRICE * 100) <= 20 THEN '16-20%'
            WHEN t.GROSS_PRICE > 0 AND (t.TOTAL_DISCOUNT / t.GROSS_PRICE * 100) <= 30 THEN '21-30%'
            ELSE '30%+'
        END AS DISCOUNT_BAND
    FROM {{ ref('stg_transactions') }} t
    WHERE t.IS_OUTLIER = FALSE
),

baseline AS (
    SELECT AVG(QUANTITY) AS baseline_qty, AVG(SALES_VALUE) AS baseline_sales
    FROM txn_with_discount_band
    WHERE DISCOUNT_PCT = 0
)

SELECT
    d.DISCOUNT_BAND,
    COUNT(*) AS NUM_TRANSACTIONS,
    ROUND(AVG(d.QUANTITY), 2) AS AVG_QUANTITY,
    ROUND(AVG(d.SALES_VALUE), 2) AS AVG_SALES_VALUE,
    ROUND(AVG(d.TOTAL_DISCOUNT), 2) AS AVG_DISCOUNT_GIVEN,
    ROUND(AVG(d.GROSS_PRICE), 2) AS AVG_GROSS_PRICE,
    ROUND(AVG(d.DISCOUNT_PCT), 2) AS AVG_DISCOUNT_PCT,
    CASE
        WHEN b.baseline_qty > 0
        THEN ROUND((AVG(d.QUANTITY) - b.baseline_qty) / b.baseline_qty * 100, 2)
        ELSE NULL
    END AS QUANTITY_LIFT_VS_BASELINE_PCT,
    CASE
        WHEN b.baseline_sales > 0
        THEN ROUND((AVG(d.SALES_VALUE) - b.baseline_sales) / b.baseline_sales * 100, 2)
        ELSE NULL
    END AS SALES_LIFT_VS_BASELINE_PCT,
    ROUND(AVG(d.SALES_VALUE) - AVG(d.TOTAL_DISCOUNT), 2) AS NET_REVENUE_AFTER_DISCOUNT
FROM txn_with_discount_band d
CROSS JOIN baseline b
GROUP BY d.DISCOUNT_BAND, b.baseline_qty, b.baseline_sales
ORDER BY AVG(d.DISCOUNT_PCT)
