
-- 05_cohort_retention.sql
-- Purpose: Monthly acquisition cohorts and their retention over
--          the following 12 months (classic cohort matrix).

CREATE OR REPLACE TABLE `nodal-buckeye-508311-r3.Retail.cohort_retention` AS
WITH first_order AS (
  SELECT
    customer_id,
    DATE_TRUNC(MIN(invoice_date), MONTH) AS cohort_month
  FROM `nodal-buckeye-508311-r3.Retail.transactions`
  GROUP BY customer_id
),
activity AS (
  SELECT
    t.customer_id,
    f.cohort_month,
    DATE_DIFF(
      DATE_TRUNC(t.invoice_date, MONTH),
      f.cohort_month,
      MONTH
    ) AS month_offset
  FROM `nodal-buckeye-508311-r3.Retail.transactions` t
  JOIN first_order f USING (customer_id)
)
SELECT
  cohort_month,
  month_offset,
  COUNT(DISTINCT customer_id) AS active_customers
FROM activity
GROUP BY cohort_month, month_offset;

WITH sized AS (
  SELECT
    cohort_month,
    month_offset,
    active_customers,
    MAX(IF(month_offset = 0, active_customers, NULL))
      OVER (PARTITION BY cohort_month) AS cohort_size
  FROM `nodal-buckeye-508311-r3.Retail.cohort_retention`
)
SELECT
  cohort_month,
  cohort_size,
  month_offset,
  active_customers,
  ROUND(100 * active_customers / cohort_size, 1) AS retention_pct
FROM sized
WHERE month_offset BETWEEN 0 AND 12
ORDER BY cohort_month, month_offset;
