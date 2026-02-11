CREATE TABLE customer_rfm AS
WITH base AS (
    SELECT
        customer_name,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(sales) AS monetary,
        (SELECT MAX(order_date) FROM sales_data) - MAX(order_date) AS recency_days
    FROM sales_data
    GROUP BY customer_name
)
SELECT *,
    CASE
        WHEN recency_days <= 30 THEN 4
        WHEN recency_days <= 60 THEN 3
        WHEN recency_days <= 120 THEN 2
        ELSE 1
    END AS r_score,

    CASE
        WHEN frequency >= 10 THEN 4
        WHEN frequency >= 6 THEN 3
        WHEN frequency >= 3 THEN 2
        ELSE 1
    END AS f_score,

    CASE
        WHEN monetary >= 20000 THEN 4
        WHEN monetary >= 10000 THEN 3
        WHEN monetary >= 5000 THEN 2
        ELSE 1
    END AS m_score
FROM base;

ALTER TABLE customer_rfm
ADD COLUMN customer_segment VARCHAR(50);

UPDATE customer_rfm
SET customer_segment =
    CASE
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'High Value'
        WHEN f_score >= 3 AND r_score >= 2 THEN 'Loyal Customers'
        WHEN r_score = 4 AND f_score = 1 THEN 'New Customers'
        WHEN r_score >= 3 AND f_score = 2 THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        ELSE 'Low Value'
    END;

SELECT customer_segment, COUNT(*)
FROM customer_rfm
GROUP BY customer_segment
ORDER BY COUNT(*) DESC;

select * from customer_rfm
