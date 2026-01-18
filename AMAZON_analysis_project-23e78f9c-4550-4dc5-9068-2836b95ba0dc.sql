--A1Q1
SELECT COALESCE (payment_type, 'N/A') as payment_type,
ROUND (AVG (payment_value)) as rounded_avg_payment FROM Payments
WHERE payment_type != 'not_defined'
AND payment_value IS NOT NULL
GROUP BY payment_type
ORDER BY rounded_avg_payment DESC;

--A1Q2
SELECT payment_type,ROUND ((COUNT(*) *100.0)/
(SELECT COUNT(*) FROM Payments), 1) as percentage_orders
FROM Payments
WHERE payment_type !='not_defined'
AND payment_value IS NOT NULL
GROUP BY payment_type
ORDER BY percentage_orders DESC;

--A1Q3
SELECT oi.product_id, price FROM order_items oi
JOIN product p
ON oi.product_id = p.product_id
WHERE price BETWEEN 100 AND 500
AND product_category_name ILIKE '%smart%'
ORDER BY oi.price DESC;

--A1Q4
SELECT TO_CHAR(order_purchase_timestamp, 'MM-YYYY') as month, 
ROUND (SUM(price)) as total_sales
FROM orders o JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY month
ORDER BY total_sales DESC
LIMIT 3;

--A1Q5
SELECT product_category_name, (MAX(price) - MIN(price)) as price_difference 
FROM product p JOIN order_items oi
ON p.product_id = oi.product_id 
GROUP BY product_category_name 
HAVING (MAX (price) - MIN(price)) > 500 ORDER BY price_difference DESC;

--A1Q6
SELECT payment_type, 
ROUND (STDDEV (payment_value), 2)as std_deviation
FROM payments
GROUP BY payment_type
ORDER BY std_deviation ASC;

--A1Q7

SELECT product_id, product_category_name FROM product
WHERE product_category_name IS NULL OR
LENGTH (product_category_name)=1;

--A2Q1
SELECT p.product_category_name,
ROUND(SUM(oi.price), 2) AS total_revenue FROM product p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;SELECT
  season,
  ROUND(SUM(total_sales), 2) AS total_sales
FROM (
  SELECT
    CASE
      WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (3, 4, 5) THEN 'Spring'
      WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (6, 7, 8) THEN 'Summer'
      WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (9, 10, 11) THEN 'Autumn'
      ELSE 'Winter'
    END AS season,
    oi.price AS total_sales
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
) AS seasonal_sales
GROUP BY season
ORDER BY total_sales DESC;

--A2Q2
SELECT product_id,total_quantity_sold
FROM (
  SELECT
    product_id,
    COUNT(*) AS total_quantity_sold
  FROM order_items
  GROUP BY product_id
) AS product_sales
WHERE total_quantity_sold > (
  SELECT
    AVG(product_count)
  FROM (
    SELECT
      COUNT(*) AS product_count
    FROM order_items
    GROUP BY product_id
  ) AS avg_sales
)
ORDER BY total_quantity_sold DESC;

--A2Q3
SELECT
  EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
  ROUND(SUM(oi.price), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY month
ORDER BY month;

--A2Q4
SELECT CASE
WHEN oi.price <200 THEN 'Low'
WHEN oi.price BETWEEN 200 AND 1000 THEN 'Medium'
ELSE 'High' END AS order_value_segment,
p.payment_type,COUNT(*) AS count FROM order_items oi
JOIN payments p ON oi.order_id = p.order_id
GROUP BY order_value_segment, p.payment_type
ORDER BY count DESC;

WITH customer_order_counts AS (
    SELECT c.customer_unique_id,
           COUNT(o.order_id) AS order_qty
    FROM customer_data c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
customer_types AS (
    SELECT customer_unique_id,
           CASE
               WHEN order_qty = 1 THEN 'New'
               WHEN order_qty BETWEEN 2 AND 4 THEN 'Returning'
               WHEN order_qty > 4 THEN 'Loyal'
           END AS customer_type
    FROM customer_order_counts
)
SELECT customer_unique_id, customer_type
FROM customer_types;

--A2Q5
SELECT p.product_category_name,
ROUND(SUM(oi.price), 2) AS total_revenue
FROM product p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;

--A3Q1

SELECT p.product_category_name,
ROUND(SUM(oi.price), 2) AS total_revenue FROM product p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;SELECT
  season,
  ROUND(SUM(total_sales), 2) AS total_sales
FROM (
  SELECT
    CASE
      WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (3, 4, 5) THEN 'Spring'
      WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (6, 7, 8) THEN 'Summer'
      WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (9, 10, 11) THEN 'Autumn'
      ELSE 'Winter'
    END AS season,
    oi.price AS total_sales
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
) AS seasonal_sales
GROUP BY season
ORDER BY total_sales DESC;

--A3Q2

SELECT product_id,total_quantity_sold
FROM (
  SELECT
    product_id,
    COUNT(*) AS total_quantity_sold
  FROM order_items
  GROUP BY product_id
) AS product_sales
WHERE total_quantity_sold > (
  SELECT
    AVG(product_count)
  FROM (
    SELECT
      COUNT(*) AS product_count
    FROM order_items
    GROUP BY product_id
  ) AS avg_sales
)
ORDER BY total_quantity_sold DESC;

--A3Q3

SELECT
  EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
  ROUND(SUM(oi.price), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY month
ORDER BY month;
--A3Q4
WITH customer_orders AS (
  SELECT customer_id,COUNT(order_id) AS total_orders
  FROM orders
  GROUP BY customer_id
),
customer_segments AS (
  SELECT 
    CASE 
      WHEN total_orders BETWEEN 1 AND 2 THEN 'Occasional'
      WHEN total_orders BETWEEN 3 AND 5 THEN 'Regular'
      ELSE 'Loyal'
    END AS customer_type
  FROM customer_orders
)
SELECT customer_type,COUNT(*) AS count
FROM customer_segments
GROUP BY customer_type
ORDER BY count DESC;

--A3Q5
WITH customer_order_totals AS (
  SELECT o.customer_id,o.order_id,SUM(oi.price) AS order_total
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.customer_id, o.order_id
),
customer_avg_order_value AS (
  SELECT customer_id,ROUND(AVG(order_total), 2) AS avg_order_value
  FROM customer_order_totals
  GROUP BY customer_id
),
ranked_customers AS (
  SELECT customer_id,avg_order_value,
  RANK() OVER (ORDER BY avg_order_value DESC) AS customer_rank
  FROM customer_avg_order_value
)
SELECT customer_id,avg_order_value,customer_rank
FROM ranked_customers
ORDER BY customer_rank
LIMIT 20;

--A3Q6
WITH RECURSIVE monthly_sales AS (
SELECT oi.product_id,DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
SUM(oi.price) AS monthly_sales FROM orders o 
JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY oi.product_id, sale_month
),
recursive_cumulative AS (
SELECT product_id,sale_month, monthly_sales AS total_sales FROM monthly_sales
UNION ALL
SELECT ms.product_id,ms.sale_month,rc.total_sales + ms.monthly_sales AS total_sales
FROM recursive_cumulative rc
JOIN monthly_sales ms ON rc.product_id = ms.product_id 
AND ms.sale_month = rc.sale_month + INTERVAL '1 month'
)
SELECT product_id,TO_CHAR(sale_month, 'YYYY-MM') AS sale_month,
ROUND(total_sales, 2) AS total_sales
FROM recursive_cumulative
ORDER BY product_id, sale_month;


--A3Q7
WITH monthly_sales AS (
SELECT p.payment_type,DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
SUM(p.payment_value) AS monthly_total FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY p.payment_type, sale_month
),
growth_calc AS (
  SELECT payment_type,sale_month,monthly_total,
  LAG(monthly_total) OVER (
      PARTITION BY payment_type 
      ORDER BY sale_month
    ) AS previous_month_total
  FROM monthly_sales
)
SELECT payment_type,TO_CHAR(sale_month, 'YYYY-MM') AS sale_month,
  ROUND(monthly_total, 2) AS monthly_total,
  ROUND(
    CASE 
      WHEN previous_month_total IS NULL THEN NULL
      WHEN previous_month_total = 0 THEN NULL
      ELSE ((monthly_total - previous_month_total) / previous_month_total) * 100
    END, 2
  ) AS monthly_change
FROM growth_calc
ORDER BY payment_type, sale_month;






