-- ============================================================
-- 03_rfm_segmentation.sql
-- Purpose: Score customers on Recency, Frequency, Monetary (1-5)
--          and label them into actionable marketing segments.
-- Dialect: BigQuery Standard SQL
-- ============================================================

CREATE OR REPLACE TABLE `nodal-buckeye-508311-r3.Retail.rfm` AS
WITH scored AS (
  SELECT
    customer_id,
    country,
    recency_days,
    frequency,
    monetary,
    -- Recency: lower days = better, so reverse the score (5 = most recent)
    6 - NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC)         AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC)          AS m_score
  FROM `nodal-buckeye-508311-r3.Retail.customers`
)
SELECT
  *,
  CONCAT(CAST(r_score AS STRING),
         CAST(f_score AS STRING),
         CAST(m_score AS STRING))                  AS rfm_cell,
  (r_score + f_score + m_score)                    AS rfm_sum,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3               THEN 'Loyal'
    WHEN r_score >= 4 AND f_score <= 2               THEN 'New / Promising'
    WHEN r_score <= 2 AND f_score >= 3               THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2 AND m_score >= 3 THEN 'Cannot Lose'
    WHEN r_score <= 2 AND f_score <= 2               THEN 'Hibernating'
    ELSE 'Needs Attention'
  END                                              AS segment
FROM scored;

-- Segment summary: size, revenue share, avg value
SELECT
  segment,
  COUNT(*)                                          AS customers,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)  AS pct_customers,
  ROUND(SUM(monetary), 2)                           AS total_revenue,
  ROUND(100 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS pct_revenue,
  ROUND(AVG(monetary), 2)                           AS avg_revenue,
  ROUND(AVG(frequency), 1)                          AS avg_orders
FROM `nodal-buckeye-508311-r3.Retail.rfm`
GROUP BY segment
ORDER BY total_revenue DESC;
