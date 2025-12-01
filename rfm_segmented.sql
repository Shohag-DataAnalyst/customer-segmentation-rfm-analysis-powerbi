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



