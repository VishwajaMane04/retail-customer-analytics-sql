
-- 01_data_cleaning.sql
-- Purpose: Turn raw_transactions into a clean, analysis-ready
--          `transactions` table.


CREATE OR REPLACE TABLE `nodal-buckeye-508311-r3.Retail.transactions` AS
SELECT
  Invoice                                            AS invoice_no,
  StockCode                                          AS stock_code,
  TRIM(Description)                                  AS description,
  Quantity                                           AS quantity,
  PARSE_TIMESTAMP('%d/%m/%Y %H:%M', InvoiceDate)     AS invoice_ts,
  DATE(PARSE_TIMESTAMP('%d/%m/%Y %H:%M', InvoiceDate)) AS invoice_date,
  Price                                              AS unit_price,
  Customer_ID                                        AS customer_id,
  Country                                            AS country,
  ROUND(Quantity * Price, 2)                         AS line_revenue,

  CASE
    WHEN MOD(ABS(FARM_FINGERPRINT(Invoice)), 10) < 4 THEN 'Offline'
    ELSE 'Online'                                                    
  END                                                AS channel
FROM `nodal-buckeye-508311-r3.Retail.raw_transactions`
WHERE

  NOT STARTS_WITH(Invoice, 'C')

  AND Customer_ID IS NOT NULL
  AND TRIM(Customer_ID) != ''

  AND Quantity > 0
  AND Price > 0

  AND SAFE.PARSE_TIMESTAMP('%d/%m/%Y %H:%M', InvoiceDate) IS NOT NULL;

-- Quick validation
SELECT
  COUNT(*)                       AS clean_rows,
  COUNT(DISTINCT customer_id)    AS customers,
  COUNT(DISTINCT invoice_no)     AS orders,
  MIN(invoice_date)              AS first_date,
  MAX(invoice_date)              AS last_date,
  ROUND(SUM(line_revenue), 2)    AS total_revenue
FROM `nodal-buckeye-508311-r3.Retail.transactions`;
