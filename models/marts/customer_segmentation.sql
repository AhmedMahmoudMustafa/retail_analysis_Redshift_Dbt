WITH customer_behavior AS (
    SELECT
        s.customer_id,
        COUNT(DISTINCT s.sale_id) AS frequency,
        SUM(s.quantity_sold) AS total_purchases,
        SUM(s.total_amount) AS total_spend,
        AVG(s.total_amount / NULLIF(s.quantity_sold, 0)) AS avg_basket_size,
        MAX(s.sale_date) AS last_purchase,
        MIN(s.sale_date) AS first_purchase
    FROM {{ ref('stg_retail__fact_sales') }} s
    GROUP BY s.customer_id
),

metrics_with_recency AS (
    SELECT *,
        DATEDIFF(
            'day',
            last_purchase,
            (SELECT MAX(sale_date) FROM {{ ref('stg_retail__fact_sales') }})
        ) AS recency_days
    FROM customer_behavior
),


rfm_scoring AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(4) OVER (ORDER BY total_spend DESC) AS m_score
    FROM metrics_with_recency
),

final_segmentation AS (
    SELECT *,
        -- Concatenated RFM score
        CAST(r_score AS VARCHAR) || CAST(f_score AS VARCHAR) || CAST(m_score AS VARCHAR) AS rfm_score,

        -- Estimated Customer Lifetime Value (simplified)
        ROUND(frequency * avg_basket_size, 2) AS est_clv,

        -- RFM-based Label
        CASE
            WHEN r_score = 4 AND f_score = 4 AND m_score >= 3 THEN 'Champion'
            WHEN r_score = 3 AND f_score = 4 THEN 'Loyal'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score = 4 AND f_score = 1 THEN 'New High Spender'
            WHEN f_score = 1 AND m_score = 1 THEN 'Lost'
            ELSE 'Others'
        END AS customer_segment_rfm,

        -- Your Original Purchase Volume Segmentation
        CASE
            WHEN total_purchases >= 500 THEN 'High-Value'
            WHEN total_purchases BETWEEN 200 AND 499 THEN 'Medium-Value'
            WHEN total_purchases < 200 THEN 'Low-Value'
            ELSE 'Unknown'
        END AS customer_segment_volume
    FROM rfm_scoring
)

SELECT *
FROM final_segmentation
ORDER BY rfm_score DESC
