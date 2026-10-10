-- 14. Category revenue and units; translate names where available.
SELECT COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category,
 SUM(i.price) AS revenue, COUNT(*) AS items, COUNT(DISTINCT i.order_id) AS orders
FROM olist_order_items_dataset i JOIN olist_orders_dataset o USING(order_id)
JOIN olist_products_dataset p USING(product_id)
LEFT JOIN product_category_name_translation t USING(product_category_name)
WHERE o.order_status='delivered' GROUP BY 1 ORDER BY revenue DESC;

-- 15. Average listed item price by category.
SELECT COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category,
 ROUND(AVG(i.price)::numeric,2) AS avg_item_price, COUNT(*) AS items
FROM olist_order_items_dataset i JOIN olist_orders_dataset o USING(order_id)
JOIN olist_products_dataset p USING(product_id) LEFT JOIN product_category_name_translation t USING(product_category_name)
WHERE o.order_status='delivered' GROUP BY 1 HAVING COUNT(*)>=20 ORDER BY avg_item_price DESC;

-- 16. Top products by delivered item sales value.
SELECT i.product_id, COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category,
 SUM(i.price) AS revenue, COUNT(*) AS units
FROM olist_order_items_dataset i JOIN olist_orders_dataset o USING(order_id)
JOIN olist_products_dataset p USING(product_id) LEFT JOIN product_category_name_translation t USING(product_category_name)
WHERE o.order_status='delivered' GROUP BY i.product_id,category ORDER BY revenue DESC LIMIT 20;
