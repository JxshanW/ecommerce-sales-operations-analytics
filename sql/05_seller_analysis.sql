-- 17. Seller sales value and order volume.
SELECT i.seller_id, s.seller_state, SUM(i.price) AS revenue, COUNT(DISTINCT i.order_id) AS orders
FROM olist_order_items_dataset i JOIN olist_orders_dataset o USING(order_id)
JOIN olist_sellers_dataset s USING(seller_id) WHERE o.order_status='delivered'
GROUP BY i.seller_id,s.seller_state ORDER BY revenue DESC LIMIT 25;

-- 18. Seller average score; review table is aggregated before joining to items.
WITH order_score AS (SELECT order_id, AVG(review_score) AS score FROM olist_order_reviews_dataset GROUP BY order_id),
seller_orders AS (SELECT DISTINCT i.seller_id,i.order_id,os.score FROM olist_order_items_dataset i
 JOIN olist_orders_dataset o USING(order_id) LEFT JOIN order_score os USING(order_id)
 WHERE o.order_status='delivered')
SELECT seller_id, ROUND(AVG(score)::numeric,2) AS avg_order_score, COUNT(*) AS orders
FROM seller_orders GROUP BY seller_id HAVING COUNT(*)>=20 ORDER BY avg_order_score;

-- 19. Seller delivery duration and late share, based on delivered orders.
WITH seller_orders AS (SELECT DISTINCT seller_id, order_id FROM olist_order_items_dataset)
SELECT so.seller_id, AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date-o.order_purchase_timestamp))/86400) AS avg_days,
 AVG((o.order_delivered_customer_date>o.order_estimated_delivery_date)::int)*100 AS late_pct
FROM seller_orders so JOIN olist_orders_dataset o USING(order_id)
WHERE o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY so.seller_id ORDER BY avg_days;
