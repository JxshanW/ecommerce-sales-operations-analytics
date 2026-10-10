-- 20. Average purchase-to-customer delivery duration and late share.
SELECT AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date-order_purchase_timestamp))/86400) AS avg_delivery_days,
 AVG((order_delivered_customer_date>order_estimated_delivery_date)::int)*100 AS delivered_after_estimate_pct
FROM olist_orders_dataset WHERE order_status='delivered' AND order_delivered_customer_date IS NOT NULL;

-- 21. Delivery duration and late percentage by customer state.
SELECT c.customer_state, COUNT(*) AS delivered_orders,
 AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date-o.order_purchase_timestamp))/86400) AS avg_days,
 AVG((o.order_delivered_customer_date>o.order_estimated_delivery_date)::int)*100 AS late_pct
FROM olist_orders_dataset o JOIN olist_customers_dataset c USING(customer_id)
WHERE o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state ORDER BY late_pct DESC;

-- 22. Estimated versus actual delivery gap by month (positive means late).
SELECT DATE_TRUNC('month',order_purchase_timestamp)::date AS month,
 AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date-order_estimated_delivery_date))/86400) AS avg_days_vs_estimate
FROM olist_orders_dataset WHERE order_status='delivered' AND order_delivered_customer_date IS NOT NULL
GROUP BY 1 ORDER BY 1;

-- 23. Order status count and share.
SELECT order_status, COUNT(*) AS orders, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),2) AS pct
FROM olist_orders_dataset GROUP BY order_status ORDER BY orders DESC;
