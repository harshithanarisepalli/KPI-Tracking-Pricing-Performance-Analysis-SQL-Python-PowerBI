--Total Revenue
SELECT ROUND(SUM(payment_amount)::numeric,2) AS total_revenue
FROM payments;

--Total Orders
SELECT COUNT(order_id) AS total_orders
FROM orders;

--Total Customers
SELECT COUNT(customer_id) AS total_customers
FROM customers;

-- Average Order Value (AOV)
SELECT
ROUND(
SUM(payment_amount)::numeric /
COUNT(DISTINCT order_id),
2
) AS average_order_value
FROM payments;

-- Revenue Per Customer
SELECT
ROUND(
SUM(payment_amount)::numeric /
COUNT(DISTINCT customer_id),
2
) AS revenue_per_customer
FROM payments
JOIN orders
ON payments.order_id = orders.order_id;

-- Successful Payments
SELECT
COUNT(*) AS successful_payments
FROM payments
WHERE payment_status='Success';

-- Revenue by Payment Method
SELECT
payment_method,
ROUND(SUM(payment_amount)::numeric,2) AS revenue
FROM payments
GROUP BY payment_method
ORDER BY revenue DESC;

-- Orders by Payment Method
SELECT
payment_method,
COUNT(*) AS total_orders
FROM payments
GROUP BY payment_method
ORDER BY total_orders DESC;

-- Average Payment Amount
SELECT
ROUND(AVG(payment_amount)::numeric,2) AS average_payment
FROM payments;

-- Highest Order Value
SELECT
MAX(payment_amount) AS highest_order
FROM payments;

-- Repeat Customers
SELECT
COUNT(*) AS repeat_customers
FROM
(
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS repeat_customer;

-- One-Time Customers
SELECT
COUNT(*) AS one_time_customers
FROM
(
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) = 1
) AS one_time_customer;

-- Customer Lifetime Value (CLV)
SELECT
o.customer_id,
COUNT(o.order_id) AS total_orders,
ROUND(SUM(p.payment_amount)::numeric,2) AS customer_lifetime_value
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY customer_lifetime_value DESC;

-- Average Customer Lifetime Value
SELECT
ROUND(AVG(customer_clv)::numeric,2) AS average_clv
FROM
(
    SELECT
    o.customer_id,
    SUM(p.payment_amount) AS customer_clv
    FROM orders o
    JOIN payments p
    ON o.order_id = p.order_id
    GROUP BY o.customer_id
) AS clv;

-- Top 10 Customers
SELECT
o.customer_id,
ROUND(SUM(p.payment_amount)::numeric,2) AS total_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Customer Purchase Frequency
SELECT
customer_id,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;

-- Retention Rate
WITH customer_orders AS
(
    SELECT
    customer_id,
    COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)

SELECT
ROUND(
100.0 *
COUNT(CASE WHEN total_orders > 1 THEN 1 END)
/ COUNT(*),
2
) AS retention_rate
FROM customer_orders;

--Revenue by Product
SELECT
oi.product_id,
ROUND(SUM(p.payment_amount)::numeric,2) AS total_revenue
FROM order_items oi
JOIN payments p
ON oi.order_id = p.order_id
GROUP BY oi.product_id
ORDER BY total_revenue DESC;

--Top 10 Best-Selling Products
SELECT
product_id,
COUNT(order_item_id) AS units_sold
FROM order_items
GROUP BY product_id
ORDER BY units_sold DESC
LIMIT 10;

--Revenue by Category
SELECT
pr.category,
ROUND(SUM(p.payment_amount)::numeric,2) AS revenue
FROM order_items oi
JOIN products pr
ON oi.product_id = pr.product_id
JOIN payments p
ON oi.order_id = p.order_id
GROUP BY pr.category
ORDER BY revenue DESC;

--Customer Cohorts
SELECT
    customer_id,
    DATE_TRUNC('month', MIN(order_date)) AS cohort_month
FROM orders
GROUP BY customer_id
ORDER BY cohort_month;

--Monthly Retention
WITH cohort AS
(
SELECT
customer_id,
DATE_TRUNC('month',MIN(order_date)) AS cohort_month
FROM orders
GROUP BY customer_id
)

SELECT
cohort_month,
DATE_TRUNC('month',o.order_date) AS order_month,
COUNT(DISTINCT o.customer_id) AS retained_customers
FROM cohort c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY cohort_month,order_month
ORDER BY cohort_month,order_month;

--Funnel Counts
SELECT
event_type,
COUNT(*) AS total_events
FROM events
GROUP BY event_type
ORDER BY total_events DESC;

--Conversion Rate
SELECT
ROUND(
100.0 *
COUNT(CASE WHEN event_type='purchase' THEN 1 END)
/ COUNT(CASE WHEN event_type='view' THEN 1 END),
2
) AS conversion_rate
FROM events;


---Root Cause Analysis
--Monthly Revenue Trend
SELECT
DATE_TRUNC('month',o.order_date) AS month,
ROUND(SUM(p.payment_amount)::numeric,2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id=p.order_id
GROUP BY month
ORDER BY month;

--Revenue by State
SELECT
c.state,
ROUND(SUM(p.payment_amount)::numeric,2) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN payments p
ON o.order_id=p.order_id
GROUP BY c.state
ORDER BY revenue DESC;

--Customer Trends
SELECT
DATE_TRUNC('month',order_date) AS month,
COUNT(DISTINCT customer_id) AS active_customers
FROM orders
GROUP BY month
ORDER BY month;