-- PostgreSQL examples. Import source CSVs using their source table names.
-- 1. Check table size and duplicate order keys.
SELECT COUNT(*) AS rows, COUNT(DISTINCT order_id) AS distinct_orders FROM olist_orders_dataset;

-- 2. Review order status mix.
SELECT order_status, COUNT(*) AS orders FROM olist_orders_dataset GROUP BY order_status ORDER BY orders DESC;

-- 3. Find missing operational timestamps by status.
SELECT order_status, COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS missing_approval,
       COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS missing_delivery
FROM olist_orders_dataset GROUP BY order_status ORDER BY order_status;

-- 4. Check item grain uniqueness.
SELECT COUNT(*) AS item_rows, COUNT(DISTINCT (order_id, order_item_id)) AS unique_order_items FROM olist_order_items_dataset;
