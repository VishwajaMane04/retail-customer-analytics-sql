
-- 02_customer_table.sql
-- Purpose: One row per customer with core lifecycle metrics.
--          Foundation for RFM, CLV, retention and channel work.

CREATE OR REPLACE TABLE `nodal-buckeye-508311-r3.Retail.customers` AS
WITH bounds AS (
  SELECT DATE_ADD(MAX(invoice_date), INTERVAL 1 DAY) AS snapshot_date
  FROM `nodal-buckeye-508311-r3.Retail.transactions`
)
SELECT
  t.customer_id,
  ANY_VALUE(t.country)                               AS country,
  MIN(t.invoice_date)                                AS first_purchase,
  MAX(t.invoice_date)                                AS last_purchase,
  DATE_DIFF((SELECT snapshot_date FROM bounds),
            MAX(t.invoice_date), DAY)                AS recency_days,
  COUNT(DISTINCT t.invoice_no)                       AS frequency,      
  ROUND(SUM(t.line_revenue), 2)                      AS monetary,        
  ROUND(SUM(t.line_revenue)
        / NULLIF(COUNT(DISTINCT t.invoice_no), 0), 2) AS avg_order_value,
  DATE_DIFF(MAX(t.invoice_date),
            MIN(t.invoice_date), DAY)                AS lifespan_days,
  SUM(t.quantity)                                    AS total_units
FROM `nodal-buckeye-508311-r3.Retail.transactions` t
GROUP BY t.customer_id;

SELECT *
FROM `nodal-buckeye-508311-r3.Retail.customers`
ORDER BY monetary DESC
LIMIT 20;