-- 28. Month-over-month revenue and percentage growth, based on purchase month.
WITH monthly AS (SELECT DATE_TRUNC('month',o.order_purchase_timestamp)::date AS month, SUM(i.price) AS revenue
 FROM olist_orders_dataset o JOIN olist_order_items_dataset i USING(order_id)
 WHERE o.order_status='delivered' GROUP BY 1), trend AS (
 SELECT month,revenue,LAG(revenue) OVER(ORDER BY month) AS prior_revenue FROM monthly)
SELECT month,revenue,prior_revenue,ROUND(100.0*(revenue-prior_revenue)/NULLIF(prior_revenue,0),2) AS growth_pct
FROM trend ORDER BY month;

-- 29. Category contribution to delivered item revenue.
WITH categories AS (SELECT COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category,
 SUM(i.price) AS revenue FROM olist_order_items_dataset i JOIN olist_orders_dataset o USING(order_id)
 JOIN olist_products_dataset p USING(product_id) LEFT JOIN product_category_name_translation t USING(product_category_name)
 WHERE o.order_status='delivered' GROUP BY 1)
SELECT category,revenue,ROUND(100.0*revenue/SUM(revenue) OVER(),2) AS revenue_share_pct,
 DENSE_RANK() OVER(ORDER BY revenue DESC) AS category_rank FROM categories ORDER BY revenue DESC;

-- 30. Top three categories within each customer state.
WITH state_category AS (SELECT c.customer_state,
 COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category,SUM(i.price) AS revenue
 FROM olist_orders_dataset o JOIN olist_customers_dataset c USING(customer_id)
 JOIN olist_order_items_dataset i USING(order_id) JOIN olist_products_dataset p USING(product_id)
 LEFT JOIN product_category_name_translation t USING(product_category_name)
 WHERE o.order_status='delivered' GROUP BY 1,2), ranked AS (
 SELECT *,ROW_NUMBER() OVER(PARTITION BY customer_state ORDER BY revenue DESC) AS position FROM state_category)
SELECT customer_state,category,revenue,position FROM ranked WHERE position<=3 ORDER BY customer_state,position;
