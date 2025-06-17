-- models/marts/store/mart_store_performance.sql

WITH sales AS (
    SELECT
        fs.product_id,
        fs.sale_id,
        fs.store_id,
        fs.sale_date,
        fs.quantity_sold,
        fs.total_amount
    FROM {{ ref('stg_retail__fact_sales') }} fs
),

store_dim AS (
    SELECT * FROM {{ ref('stg_retail__dim_stores') }}
),

date_dim AS (
    SELECT * FROM {{ ref('stg_retail__dim_time') }}
),

product_dim AS (
    SELECT * FROM {{ ref('stg_retail__dim_products') }}
),

sales_enriched AS (
    SELECT
        s.sale_id,
        s.store_id,
        d.date_id,
        d.month,
        d.year,
        p.category,
        p.price,
        st.store_name,
        st.location,
        st.manager_name,
        s.quantity_sold,
        s.total_amount
    FROM sales s
    LEFT JOIN date_dim d ON s.sale_date = d.date_id
    LEFT JOIN store_dim st ON s.store_id = st.store_id
    LEFT JOIN product_dim p ON s.product_id = p.product_id
)

SELECT
    store_id,
    store_name,
    category,
    location,
    year,
    month,
    COUNT(sale_id) AS number_of_sales,
    SUM(quantity_sold) AS total_quantity_sold,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(AVG(price), 2) AS avg_product_price
FROM sales_enriched
WHERE category IS NOT NULL
GROUP BY store_id, store_name, location, category, year, month
