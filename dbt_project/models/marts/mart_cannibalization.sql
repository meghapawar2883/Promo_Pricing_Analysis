WITH product_dept AS (
    SELECT PRODUCT_ID, DEPARTMENT, COMMODITY_DESC
    FROM {{ ref('stg_products') }}
),

promo_weeks AS (
    SELECT DISTINCT
        c.PRODUCT_ID,
        c.STORE_ID,
        c.WEEK_NO,
        p.DEPARTMENT,
        p.COMMODITY_DESC
    FROM {{ ref('stg_causal') }} c
    JOIN product_dept p ON c.PRODUCT_ID = p.PRODUCT_ID
    WHERE c.IS_PROMOTED = TRUE
),

promoted_product_sales AS (
    SELECT
        pw.DEPARTMENT,
        pw.COMMODITY_DESC,
        pw.STORE_ID,
        pw.WEEK_NO,
        pw.PRODUCT_ID AS PROMOTED_PRODUCT_ID,
        SUM(t.SALES_VALUE) AS PROMOTED_PRODUCT_REVENUE
    FROM promo_weeks pw
    JOIN {{ ref('stg_transactions') }} t
        ON pw.PRODUCT_ID = t.PRODUCT_ID
        AND pw.STORE_ID = t.STORE_ID
        AND pw.WEEK_NO = t.WEEK_NO
    GROUP BY 1, 2, 3, 4, 5
),

same_category_other_products AS (
    SELECT
        pw.DEPARTMENT,
        pw.COMMODITY_DESC,
        pw.STORE_ID,
        pw.WEEK_NO,
        pw.PRODUCT_ID AS PROMOTED_PRODUCT_ID,
        SUM(t.SALES_VALUE) AS OTHER_PRODUCT_REVENUE,
        COUNT(DISTINCT t.PRODUCT_ID) AS OTHER_PRODUCTS_COUNT
    FROM promo_weeks pw
    JOIN product_dept p2 ON pw.COMMODITY_DESC = p2.COMMODITY_DESC AND pw.PRODUCT_ID != p2.PRODUCT_ID
    JOIN {{ ref('stg_transactions') }} t
        ON p2.PRODUCT_ID = t.PRODUCT_ID
        AND pw.STORE_ID = t.STORE_ID
        AND pw.WEEK_NO = t.WEEK_NO
    GROUP BY 1, 2, 3, 4, 5
),

non_promo_baseline AS (
    SELECT
        p.COMMODITY_DESC,
        t.STORE_ID,
        AVG(t.SALES_VALUE) AS BASELINE_AVG_SALES
    FROM {{ ref('stg_transactions') }} t
    JOIN product_dept p ON t.PRODUCT_ID = p.PRODUCT_ID
    LEFT JOIN {{ ref('stg_causal') }} c
        ON t.PRODUCT_ID = c.PRODUCT_ID
        AND t.STORE_ID = c.STORE_ID
        AND t.WEEK_NO = c.WEEK_NO
    WHERE COALESCE(c.IS_PROMOTED, FALSE) = FALSE
    GROUP BY 1, 2
)

SELECT
    pps.DEPARTMENT,
    pps.COMMODITY_DESC,
    COUNT(DISTINCT pps.PROMOTED_PRODUCT_ID) AS NUM_PROMOTED_PRODUCTS,
    ROUND(AVG(pps.PROMOTED_PRODUCT_REVENUE), 2) AS AVG_PROMOTED_REVENUE,
    ROUND(AVG(scop.OTHER_PRODUCT_REVENUE), 2) AS AVG_OTHER_CATEGORY_REVENUE,
    ROUND(AVG(nb.BASELINE_AVG_SALES), 2) AS CATEGORY_BASELINE_AVG,
    CASE
        WHEN AVG(nb.BASELINE_AVG_SALES) > 0
        THEN ROUND((AVG(scop.OTHER_PRODUCT_REVENUE) - AVG(nb.BASELINE_AVG_SALES)) / AVG(nb.BASELINE_AVG_SALES) * 100, 2)
        ELSE NULL
    END AS CANNIBALIZATION_PCT,
    CASE
        WHEN AVG(nb.BASELINE_AVG_SALES) > 0
        AND (AVG(scop.OTHER_PRODUCT_REVENUE) - AVG(nb.BASELINE_AVG_SALES)) / AVG(nb.BASELINE_AVG_SALES) * 100 < -10
        THEN 'HIGH CANNIBALIZATION'
        WHEN AVG(nb.BASELINE_AVG_SALES) > 0
        AND (AVG(scop.OTHER_PRODUCT_REVENUE) - AVG(nb.BASELINE_AVG_SALES)) / AVG(nb.BASELINE_AVG_SALES) * 100 < -5
        THEN 'MODERATE CANNIBALIZATION'
        ELSE 'LOW / NO CANNIBALIZATION'
    END AS CANNIBALIZATION_LEVEL
FROM promoted_product_sales pps
LEFT JOIN same_category_other_products scop
    ON pps.COMMODITY_DESC = scop.COMMODITY_DESC
    AND pps.STORE_ID = scop.STORE_ID
    AND pps.WEEK_NO = scop.WEEK_NO
    AND pps.PROMOTED_PRODUCT_ID = scop.PROMOTED_PRODUCT_ID
LEFT JOIN non_promo_baseline nb
    ON pps.COMMODITY_DESC = nb.COMMODITY_DESC
    AND pps.STORE_ID = nb.STORE_ID
GROUP BY 1, 2
HAVING COUNT(DISTINCT pps.PROMOTED_PRODUCT_ID) >= 3
