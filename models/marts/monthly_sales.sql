WITH sales_by_month AS (
   SELECT
       DATE_TRUNC('month', sale_date) AS sales_month,
       EXTRACT(YEAR FROM sale_date) AS year,
       EXTRACT(MONTH FROM sale_date) AS month,
       SUM(total_amount) AS total_sales,
       COUNT(DISTINCT sale_id) AS total_transactions
   FROM {{ ref('stg_retail__fact_sales') }}
   GROUP BY 1,2,3
)


SELECT
   sales_month,
   year,
   month,
   total_sales,
   total_transactions,
   ROUND(
      total_sales / NULLIF(total_transactions, 0), 2
   ) AS avg_sales_per_transaction,

   ROUND(
      100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY sales_month))
        / NULLIF(LAG(total_sales) OVER (ORDER BY sales_month), 0),
        2
    ) AS mom_sales_change_pct,

    SUM(total_sales) OVER (
        PARTITION BY year
        ORDER BY sales_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_sales
FROM sales_by_month
ORDER BY month