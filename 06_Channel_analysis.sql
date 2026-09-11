
-- 06_channel_analysis.sql
-- Purpose: Compare Offline vs Online (O+O) performance and find
--          omnichannel customers (those who shop BOTH channels)
--          and their value premium.

-- 1) Headline metrics per channel
SELECT
  channel,
  COUNT(DISTINCT customer_id)                        AS customers,
  COUNT(DISTINCT invoice_no)                         AS orders,
  ROUND(SUM(line_revenue), 2)                        AS revenue,
  ROUND(SUM(line_revenue)
        / COUNT(DISTINCT invoice_no), 2)             AS avg_order_value,
  ROUND(COUNT(DISTINCT invoice_no)
        / COUNT(DISTINCT customer_id), 2)            AS orders_per_customer,
  ROUND(SUM(line_revenue)
        / COUNT(DISTINCT customer_id), 2)            AS revenue_per_customer
FROM `nodal-buckeye-508311-r3.Retail.transactions`
GROUP BY channel
ORDER BY revenue DESC;

-- 2) Omnichannel vs single-channel customers
WITH cust_channels AS (
  SELECT
    customer_id,
    COUNT(DISTINCT channel)     AS channel_count,
    ROUND(SUM(line_revenue), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no)  AS orders
  FROM `nodal-buckeye-508311-r3.Retail.transactions`
  GROUP BY customer_id
)
SELECT
  CASE WHEN channel_count = 2 THEN 'Omnichannel (O+O)'
       ELSE 'Single channel' END                    AS customer_type,
  COUNT(*)                                           AS customers,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)   AS pct_customers,
  ROUND(AVG(total_revenue), 2)                       AS avg_revenue_per_customer,
  ROUND(AVG(orders), 1)                              AS avg_orders,
  ROUND(100 * SUM(total_revenue)
        / SUM(SUM(total_revenue)) OVER (), 1)        AS pct_of_total_revenue
FROM cust_channels
GROUP BY customer_type
ORDER BY avg_revenue_per_customer DESC;
