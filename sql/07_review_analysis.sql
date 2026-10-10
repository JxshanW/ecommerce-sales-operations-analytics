-- 24. Average score and review count.
SELECT COUNT(*) AS review_records, ROUND(AVG(review_score)::numeric,2) AS avg_score FROM olist_order_reviews_dataset;

-- 25. Review score distribution.
SELECT review_score, COUNT(*) AS reviews, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),2) AS pct
FROM olist_order_reviews_dataset GROUP BY review_score ORDER BY review_score;

-- 26. Category average score, with order scores deduplicated before item join.
WITH order_score AS (SELECT order_id, AVG(review_score) AS score FROM olist_order_reviews_dataset GROUP BY order_id),
category_orders AS (SELECT DISTINCT i.order_id,COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category
 FROM olist_order_items_dataset i JOIN olist_orders_dataset o USING(order_id)
 JOIN olist_products_dataset p USING(product_id) LEFT JOIN product_category_name_translation t USING(product_category_name)
 WHERE o.order_status='delivered')
SELECT co.category, ROUND(AVG(os.score)::numeric,2) AS avg_score, COUNT(*) AS orders
FROM category_orders co JOIN order_score os USING(order_id)
GROUP BY co.category HAVING COUNT(*)>=20 ORDER BY avg_score;

-- 27. Review score versus delivery after estimate; score is averaged to order level.
WITH order_score AS (SELECT order_id, AVG(review_score) AS score FROM olist_order_reviews_dataset GROUP BY order_id)
SELECT CASE WHEN o.order_delivered_customer_date>o.order_estimated_delivery_date THEN 'late'
            ELSE 'on_or_before_estimate' END AS delivery_group,
 COUNT(*) AS orders, ROUND(AVG(os.score)::numeric,2) AS avg_score
FROM olist_orders_dataset o JOIN order_score os USING(order_id)
WHERE o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1 ORDER BY 1;
