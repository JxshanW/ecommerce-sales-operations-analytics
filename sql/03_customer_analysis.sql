-- 10. Unique people and repeat customer share (customer_unique_id).
WITH customer_orders AS (SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS orders
 FROM olist_customers_dataset c JOIN olist_orders_dataset o USING(customer_id)
 WHERE o.order_status='delivered' GROUP BY c.customer_unique_id)
SELECT COUNT(*) AS customers, COUNT(*) FILTER(WHERE orders>1) AS repeat_customers,
 ROUND(100.0*COUNT(*) FILTER(WHERE orders>1)/COUNT(*),2) AS repeat_pct FROM customer_orders;

-- 11. Highest-value customers by delivered item sales.
SELECT c.customer_unique_id, SUM(i.price) AS revenue, COUNT(DISTINCT o.order_id) AS orders
FROM olist_customers_dataset c JOIN olist_orders_dataset o USING(customer_id)
JOIN olist_order_items_dataset i USING(order_id) WHERE o.order_status='delivered'
GROUP BY c.customer_unique_id ORDER BY revenue DESC LIMIT 20;

-- 12. Distribution of delivered-order frequency per customer.
WITH customer_orders AS (SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS order_count
 FROM olist_customers_dataset c JOIN olist_orders_dataset o USING(customer_id)
 WHERE o.order_status='delivered' GROUP BY c.customer_unique_id)
SELECT order_count, COUNT(*) AS customers FROM customer_orders GROUP BY order_count ORDER BY order_count;

-- 13. Time between consecutive orders for repeat customers, in days.
WITH purchase_dates AS (SELECT c.customer_unique_id, o.order_id, o.order_purchase_timestamp,
 LAG(o.order_purchase_timestamp) OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS prior_order
 FROM olist_customers_dataset c JOIN olist_orders_dataset o USING(customer_id) WHERE o.order_status='delivered')
SELECT customer_unique_id, order_id, EXTRACT(EPOCH FROM (order_purchase_timestamp-prior_order))/86400 AS days_between
FROM purchase_dates WHERE prior_order IS NOT NULL ORDER BY days_between;
