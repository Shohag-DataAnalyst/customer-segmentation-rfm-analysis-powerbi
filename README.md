# customer-segmentation-rfm-analysis-powerbi
Customer segmentation project using RFM (Recency, Frequency, Monetary) analysis with SQL and Power BI. Includes SQL scoring logic, segmentation rules, and an interactive dashboard.

---

## 📁 Project Overview

This project performs customer segmentation using the **RFM (Recency, Frequency, Monetary)** model.

Using SQL, I generated:

- Customer purchase history  
- RFM scores (1–5)  
- Final RFM codes (e.g., 545, 321, etc.)  
- Segments such as *Champions*, *Loyal*, *Big Spenders*, *At Risk*, and *Hibernating*

The final results were visualized in Power BI to create an interactive dashboard showing:

- Segment distribution  
- Revenue contribution by segment  
- Key performance metrics  
- Customer behavior patterns  
- Activity vs Spending relationships

This project demonstrates end-to-end analytics skills:  
**SQL → Data Modeling → Segmentation Logic → Power BI Dashboard → Business Insights**

---

## 🗄️ SQL Pipeline (RFM Logic)

This project uses SQL to calculate **Recency, Frequency, Monetary** scores for every customer.

### 1️⃣ Base Customer Summary
Counts each customer’s orders, total revenue, and their most recent purchase date.

```sql
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
	customer_key,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(revenue) AS total_revenue,
	MAX(order_date) AS last_order_date
FROM vw_sales
GROUP BY customer_key;


CREATE OR REPLACE VIEW vw_rfm_base AS 
WITH snapshot AS (
	SELECT 
		MAX(order_date) AS snapshot_date
	FROM vw_sales
)
SELECT
	cs.customer_key,
	cs.total_orders AS frequency,
	cs.total_revenue AS monetary,
	cs.last_order_date,
    s.snapshot_date,
	(s.snapshot_date - cs.last_order_date) AS recency_days
FROM vw_customer_summary AS cs
CROSS JOIN snapshot AS s


CREATE OR REPLACE VIEW vw_rfm_scores AS
SELECT
    customer_key,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days ASC) AS r_raw,
    NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
FROM vw_rfm_base;



CREATE OR REPLACE VIEW vw_rfm_final AS
SELECT
    customer_key,
    recency_days,
    frequency,
    monetary,
    (6 - r_raw) AS r_score,
    f_score,
    m_score,
    CONCAT((6 - r_raw), f_score, m_score) AS rfm_code
FROM vw_rfm_scores;




CREATE OR REPLACE VIEW vw_rfm_segmented AS
SELECT
    customer_key,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    rfm_code,

    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN f_score >= 4 AND r_score >= 3 THEN 'Loyal'
        WHEN m_score >= 4 AND f_score BETWEEN 2 AND 3 THEN 'Big Spenders'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score = 1 AND f_score <= 2 THEN 'Hibernating'
        ELSE 'Others'
    END AS segment

FROM vw_rfm_final;

```
---

## 📊 Power BI Dashboard

The final dashboard presents customer segments, spending behavior, and key business insights clearly and interactively.

### 📌 Dashboard Preview

> ![Dashboard Screenshot](https://github.com/Shohag-DataAnalyst/customer-segmentation-rfm-analysis-powerbi/blob/main/Screenshot/Dashboard.png?raw=true)

---

## 🖥️ Dashboard Pages & Insights

### 1️⃣ Segment Distribution (Pie Chart)
Shows the percentage of customers in each segment:
- **Champions** → most engaged customers  
- **Loyal** → frequent buyers  
- **Big Spenders** → high-value customers  
- **At Risk** → potential churn  
- **Hibernating** → inactive customers  
- **Others** → neutral group

---

### 2️⃣ Key Metrics (Top KPI Cards)
- **Total Customers**  
- **Total Revenue**  
- **Average Recency (Days)**  

These KPIs summarize customer activity at a glance.

---

### 3️⃣ Revenue by Segment (Bar Chart)
Reveals which segments contribute the most revenue.  
This helps businesses target the highest-value groups with offers and retention strategies.

---

### 4️⃣ Segment Summary Table
Shows segment-level averages:
- Average Recency  
- Average Frequency  
- Average Monetary Value  
- Customer Count  

Useful for comparing customer groups side-by-side.

---

### 5️⃣ Customer Activity vs Spending (Scatter Plot)
Highlights the relationship between:
- **Purchase Frequency**  
- **Total Spending**  

Color-coded by segment to identify:
- High-value clusters  
- At-risk behavior  
- Low-value groups  
