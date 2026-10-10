-- 5. Total realized item revenue (delivered orders; freight excluded).
SELECT ROUND(SUM(i.price)::numeric, 2) AS item_revenue FROM olist_order_items_dataset i
JOIN olist_orders_dataset o USING (order_id) WHERE o.order_status = 'delivered';

-- 6. Delivered orders and average item value per order.
WITH order_sales AS (SELECT i.order_id, SUM(i.price) AS item_value FROM olist_order_items_dataset i
 JOIN olist_orders_dataset o USING(order_id) WHERE o.order_status='delivered' GROUP BY i.order_id)
SELECT COUNT(*) AS orders, ROUND(AVG(item_value)::numeric,2) AS average_order_value FROM order_sales;

-- 7. Monthly revenue and order count by purchase month.
SELECT DATE_TRUNC('month',o.order_purchase_timestamp)::date AS month, SUM(i.price) AS revenue,
       COUNT(DISTINCT o.order_id) AS orders
FROM olist_orders_dataset o JOIN olist_order_items_dataset i USING(order_id)
WHERE o.order_status='delivered' GROUP BY 1 ORDER BY 1;

-- 8. Payment mix; payment_value is transaction value, not item revenue.
SELECT payment_type, SUM(payment_value) AS payment_value,
       COUNT(DISTINCT order_id) AS orders, AVG(payment_installments) AS avg_installments
FROM olist_order_payments_dataset GROUP BY payment_type ORDER BY payment_value DESC;

-- 9. Revenue and order volume by customer state.
SELECT c.customer_state, SUM(i.price) AS revenue, COUNT(DISTINCT o.order_id) AS orders
FROM olist_orders_dataset o JOIN olist_customers_dataset c USING(customer_id)
JOIN olist_order_items_dataset i USING(order_id) WHERE o.order_status='delivered'
GROUP BY c.customer_state ORDER BY revenue DESC;
