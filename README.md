<p align="center">
  <img src="https://img.shields.io/badge/Skills-SQL-blue?style=for-the-badge" alt="SQL">
  <img src="https://img.shields.io/badge/Tool-Power%20BI-yellow?style=for-the-badge" alt="Power BI">
  <img src="https://img.shields.io/badge/Database-PostgreSQL-336791?style=for-the-badge" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge" alt="Completed">
</p>

---

# 📊 Customer Segmentation Using RFM Analysis (SQL + Power BI)
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

## 📄 Data Description

This project uses a transactional sales table (`vw_sales`) that includes:

- `order_date` — date of purchase  
- `order_number` — unique order identifier  
- `customer_key` — customer ID  
- `product_key` — product identifier  
- `order_quantity` — number of units  
- `product_price` — price per unit  
- `revenue` — calculated as (quantity × price)

These fields are enough to generate:

- Recency (last order date)
- Frequency (total orders)
- Monetary Value (total spending)

The project does **not** rely on any external dataset —  
it uses transformed data from SQL views created earlier in the pipeline.


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

### 3️⃣ Revenue by Segment (Clustered Column Chart)
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

---

## 💡 Key Business Insights

Here are the main insights discovered from the RFM analysis:

### 🔹 1. Champions Drive the Most Revenue
Customers classified as **Champions** contribute the highest revenue.  
They buy frequently, spend the most, and have very recent activity.  
These customers should be prioritized with loyalty programs and exclusive offers.

---

### 🔹 2. Loyal Customers Are Highly Engaged
The **Loyal** segment makes consistent purchases and shows strong engagement.  
They react well to:
- Discounts  
- Early product releases  
- Membership perks  

---

### 🔹 3. Big Spenders Show High Monetary Value but Lower Frequency
This group spends a lot but does not buy often.  
They can be upsold through:
- Premium bundles  
- Personalized recommendations  
- Targeted remarketing campaigns  

---

### 🔹 4. At Risk Customers Show Signs of Churn
These customers previously purchased often but haven’t bought in a long time.  
They may be recovered with:
- Win-back campaigns  
- Urgent limited-time offers  
- Email reminders  

---

### 🔹 5. Hibernating Customers Are Mostly Inactive
This group has:
- Long recency  
- Low frequency  
- Low monetary value  

Usually low priority, but they can be targeted with low-cost reactivation campaigns.

---

### 🔹 6. Clear Relationship Between Frequency and Spending
The scatter plot shows that as **frequency increases**, total spending also increases.  
High-value clusters are clearly visible, helping businesses identify their strongest revenue drivers.

---

## ▶️ How to Run This Project

### 1️⃣ Requirements

To replicate this project, you need:

- PostgreSQL (or any SQL database)
- Power BI Desktop
- A fact table containing customer order history  
  (order date, customer ID, product price, quantity, etc.)

---

### 2️⃣ SQL Setup

Run the SQL scripts in this order:

1. `vw_customer_summary`  
2. `vw_rfm_base`  
3. `vw_rfm_scores`  
4. `vw_rfm_final`  
5. `vw_rfm_segmented`

These views will generate:

- Recency (days since last purchase)  
- Frequency (number of orders)  
- Monetary value (total spend)  
- RFM scores (1–5)  
- Segment classification

---

### 3️⃣ Power BI Setup

1. Open **Power BI Desktop**  
2. Connect to your PostgreSQL database  
3. Load the view:
4. Refresh the data  
5. The dashboard will automatically calculate and visualize:

- Segment distribution  
- Total revenue  
- Customer behavior  
- RFM values  
- Spending patterns  

---

### 4️⃣ Optional: Replace with Your Dataset  
If you want to apply this to your own data:

- Replace `vw_sales` with your own fact table  
- Make sure the table includes:
  - customer_key  
  - order_date  
  - order_number  
  - revenue  

Everything else will still work.

---

## 🧠 Skills Demonstrated

This project showcases several key data analytics and business intelligence skills:

### 🔹 SQL Data Processing
- Joins, aggregations, window functions  
- Ranking and segmentation logic  
- Creating reusable SQL views  
- RFM scoring methodology  

### 🔹 Data Modeling
- Creating a clean analytical pipeline  
- Designing customer-level summary tables  
- Managing snapshot dates and recency metrics  

### 🔹 Business Intelligence (Power BI)
- Building interactive dashboards  
- Using slicers, KPI cards, charts, and scatter plots  
- Consistent color themes and UI design  
- Turning data into meaningful business insights  

### 🔹 Analytical Thinking
- Identifying high-value customer segments  
- Marketing recommendations based on behavioral data  
- Revenue impact analysis  

---

## ✅ Conclusion

This RFM Customer Segmentation project takes raw transactional data and transforms it into actionable business insights.  
It demonstrates the complete analytics workflow:

**Data → SQL Modeling → RFM Scoring → Segmentation → Dashboard → Insights**

This project reflects strong analytical thinking, technical skills, and the ability to build end-to-end solutions that support data-driven decision making.

If you found this project useful or have feedback, feel free to connect or reach out!
