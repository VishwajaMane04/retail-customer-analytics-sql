
-- 04_clv.sql
-- Purpose: Historical Customer Lifetime Value + a simple
--          predictive annualised CLV estimate. Rank top customers
--          and quantify revenue concentration (Pareto).

-- 1) Historical CLV per customer with a naive forward estimate
CREATE OR REPLACE TABLE `nodal-buckeye-508311-r3.Retail.clv` AS
SELECT
  customer_id,
  country,
  frequency                                          AS orders,
  monetary                                           AS historical_clv,
  avg_order_value,
  lifespan_days,
  ROUND(frequency / (GREATEST(lifespan_days, 1) / 30.0), 2) AS orders_per_month,
  ROUND(avg_order_value
        * (frequency / (GREATEST(lifespan_days, 1) / 30.0))
        * 12, 2)                                     AS est_annual_clv
FROM `nodal-buckeye-508311-r3.Retail.customers`;

SELECT
  customer_id, country, orders, historical_clv, avg_order_value, est_annual_clv
FROM `nodal-buckeye-508311-r3.Retail.clv`
ORDER BY historical_clv DESC
LIMIT 20;

WITH ranked AS (
  SELECT
    customer_id,
    historical_clv,
    NTILE(10) OVER (ORDER BY historical_clv DESC) AS decile
  FROM `nodal-buckeye-508311-r3.Retail.clv`
)
SELECT
  decile,
  COUNT(*)                                           AS customers,
  ROUND(SUM(historical_clv), 2)                      AS revenue,
  ROUND(100 * SUM(historical_clv)
        / SUM(SUM(historical_clv)) OVER (), 1)       AS pct_of_total_revenue
FROM ranked
GROUP BY decile
ORDER BY decile;
