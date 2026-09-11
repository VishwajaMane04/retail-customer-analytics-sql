# Omnichannel Customer Segmentation & Value Analysis (SQL / BigQuery)

*End-to-end SQL analysis of 500K+ retail transactions to uncover customer behaviour across Offline + Online (O+O) channels — covering segmentation, customer lifetime value, cohort retention, and acquisition trends, with commercial recommendations.*

## Business questions
- Who are our most valuable customers, and what share of revenue do they drive?
- How do customers behave differently across offline vs online channels?
- How well do we retain customers after their first purchase?
- Where are the biggest opportunities to improve loyalty, retention and CLV?

## Dataset

Online Retail II (UCI) — real transactions from a UK online retailer, Dec 2009–Dec 2011. 8 columns: Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer ID, Country. Loaded into Google BigQuery (~542K rows in this build).

## Tech

Google BigQuery (Standard SQL) — CTEs, window functions (NTILE, LAG), PARSE_TIMESTAMP, cohort logic.

## How it's structured 

| File | What it does |
|------|--------------|
| `01_data_cleaning.sql` | Parse dates, drop cancellations / bad rows / null customers, add channel flag → `transactions` |
| `02_customer_table.sql` | One row per customer: recency, frequency, monetary, AOV, lifespan → `customers` |
| `03_rfm_segmentation.sql` | RFM 1–5 scoring + segment labels (Champions, Loyal, At Risk…) → `rfm` |
| `04_clv.sql` | Historical + estimated annual CLV, top customers, revenue concentration → `clv` |
| `05_cohort_retention.sql` | Monthly acquisition cohorts × 12-month retention matrix |
| `06_channel_analysis.sql` | Offline vs Online metrics + omnichannel value premium |
| `07_acquisition_trends.sql` | New vs returning revenue, MoM growth, churn snapshot |


## Key Insights
- Omnichannel (O+O) customers are worth ~5x more. Customers who shop both offline and online generate £3,435 in average revenue vs £656 for single-channel customers, a 5.2x premium. O+O customers are ~50% of the base but drive 84.1% of total revenue.
- Revenue is highly concentrated. The top 10% of customers generate 61.4% of all revenue, so losing a handful of these has an outsized impact.
- A few segments carry the business. Champions and Loyal customers are ~45% of the base but drive ~82% of revenue; Champions alone (21.7% of customers) account for 64.2% of revenue.
- Retention drops sharply after the first purchase. Across acquisition cohorts, month-1 retention falls to roughly 15-37% and sits around 20-28% by month 3, so most first-time buyers do not return within a month.
- A third of customers have churned. 33.4% of customers are inactive for 90+ days, representing £1.03M of revenue at stake, a large and addressable win-back opportunity.
- "At Risk" customers still hold value. This segment (15.2% of customers) represents 9.7% of revenue, a clear high-value re-engagement target.

## Business Recommendations

- Convert single-channel customers to omnichannel (O+O). With O+O customers worth ~5x more, actively bridge channels (click-and-collect, online sign-ups at the till, in-store returns of online orders) to lift lifetime   value. This is the single biggest growth lever in the data.
- Protect the top decile with a VIP programme. Since 10% of customers drive 61% of revenue, prioritise retention here with early access, loyalty rewards and proactive outreach before they lapse.
- Double down on Champions and Loyal. Shift budget from broad acquisition toward retaining and growing the segments that already generate ~82% of revenue.
- Fix early retention with a first-30-day nudge. Given low month-1 retention, introduce a second-purchase incentive and post-purchase onboarding to convert one-time buyers into repeat customers.
- Launch a structured win-back for the 33% churned base. With £1.03M of revenue at stake, target recently-lapsed high-value customers with time-limited offers to recover at-risk revenue.
- Run a targeted "At Risk" campaign. This segment still holds ~10% of revenue, a low-cost high-return re-engagement play.



