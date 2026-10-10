# Power BI dashboard requirements

## Suggested model

Use separate source tables and explicit one-to-many relationships. Orders is the order-level fact for dates/status/delivery. Order items is the line-level fact for item revenue, connected to orders, products and sellers. Customers joins orders on `customer_id`; use `customer_unique_id` for distinct customer counts. Aggregate payments and reviews to `order_id` in Power Query or separate summary tables before relating them to order-level visuals. Never join raw payments and raw items together and then sum either amount.

Set the date table to cover purchase dates. Use purchase date for sales trends. Use delivery dates only for delivery analysis. Category labels come from the translation table with source category as a fallback.

## Measures

- **Total Revenue** = sum of `order_items[price]` for delivered orders. This is item sales value, excluding freight and refunds/adjustments. Do not label it profit.
- **Total Orders** = distinct count of `orders[order_id]` (show all statuses unless page/filter states otherwise).
- **Total Customers** = distinct count of `customer_unique_id` among customers with a delivered order in the current filter context, matching the repeat-customer population.
- **Average Order Value** = delivered item revenue / distinct delivered orders.
- **Average Review Score** = average order-level score (first aggregate multiple review records for the same order).
- **Delivery Delay %** = delivered orders after estimated delivery date / delivered orders with both actual and estimated timestamps.
- **Repeat Customers** = distinct customer_unique_id with more than one delivered order; calculate from an order count by customer table.
- **Average Delivery Time** = average elapsed days from purchase to customer delivery among delivered orders with both timestamps.

## Page 1 — Executive Overview

KPI cards: Total Revenue, Total Orders, Total Customers, Average Order Value, Average Review Score, Delivery Delay %.

Visuals: monthly revenue line chart, monthly order columns, revenue by category bar chart, revenue by customer state bar/map, top categories table or bar chart. Keep status filters visible because revenue excludes non-delivered orders.

## Page 2 — Customer & Product

Visuals: repeat versus one-time customers, top customers by delivered item sales, top categories and products, review score by category. Provide a note that customer identity uses `customer_unique_id`; use a minimum order threshold when ranking categories by score.

## Page 3 — Operations

Visuals: average delivery time, delayed delivered orders, delivery days and late share by customer state, seller sales and delivery summary, review score by on-time/late group, order status distribution.

## Slicers and design

Recommended slicers: purchase date, customer state, category, order status and seller. Use a clean layout with consistent units, readable labels, and a tooltip/footnote defining revenue and delay denominator. Do not exceed the listed visuals without a clear business question.
