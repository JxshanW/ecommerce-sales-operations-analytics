# Build the Power BI report

This is a hands-on checklist for creating the missing `.pbix` report. The `.pbix` is a Power BI Desktop file that you create and save; `dashboard_requirements.md` is only the design plan.

## 1. Start a report and load the source tables

1. Open Power BI Desktop and choose **Get data > Text/CSV**.
2. Load `orders`, `order_items`, `customers`, `products`, `sellers`, `order_reviews`, and `product_category_name_translation` from `data/raw`. You can add payments later for a payment page. Do not load geolocation for this first version: ZIP prefixes repeat and can duplicate results if joined directly.
3. Choose **Transform data** before loading.

In Power Query:

- Rename tables to `Orders`, `Order Items`, `Customers`, `Products`, `Sellers`, `Reviews`, and `Category Translation` so formulas are easier to read.
- Set ID and ZIP columns to **Text**, monetary/count columns to the correct numeric type, review score to whole number, and dates/timestamps to Date or Date/Time.
- In `Orders`, merge `Customers` on `customer_id` (left outer), and expand only `customer_unique_id` and `customer_state`. This lets date/state filters count actual people using `customer_unique_id`.
- In `Products`, merge `Category Translation` on `product_category_name` (left outer), and expand `product_category_name_english`. Use the English field in visuals; missing translations can stay blank or be filled with the source category.
- Create a query named `Review Summary`: reference `Reviews`, keep `order_id` and `review_score`, then **Group By** `order_id` and take the average of `review_score`. Use this one-row-per-order table in the report so repeated reviews do not give an order extra weight.
- Select **Close & Apply**.

## 2. Check the model relationships

In Model view, create or verify these relationships. Use **One-to-many (1:*)**, with single-direction filtering from the one side to the many side:

| One side | Many side | Columns |
|---|---|---|
| Orders | Order Items | `order_id` |
| Products | Order Items | `product_id` |
| Sellers | Order Items | `seller_id` |
| Orders | Review Summary | `order_id` (**1:1**, because Review Summary has one row per order with a review) |

Orders to Order Items, Products to Order Items and Sellers to Order Items are **1:***. Do not connect raw `Reviews` to the report measures if using `Review Summary`. `Customers` and `Category Translation` can remain loaded for reference, but their useful fields have been merged into Orders and Products. Avoid bidirectional relationships and many-to-many relationships for this beginner version.

## 3. Add a few simple measures

First select `Orders`, choose **New column**, and create `Late Flag` and `Delivery Group`. Then choose **New measure** and add the measures below. If Power BI expects semicolons due to regional settings, replace commas with semicolons.

```DAX
Late Flag =
Orders[order_status] = "delivered"
    && NOT(ISBLANK(Orders[order_delivered_customer_date]))
    && NOT(ISBLANK(Orders[order_estimated_delivery_date]))
    && Orders[order_delivered_customer_date] > Orders[order_estimated_delivery_date]

Delivery Group =
IF(
    Orders[Late Flag],
    "Late",
    IF(
        Orders[order_status] = "delivered"
            && NOT(ISBLANK(Orders[order_delivered_customer_date]))
            && NOT(ISBLANK(Orders[order_estimated_delivery_date])),
        "On/before estimate",
        "No completed delivery"
    )
)
```

```DAX
Delivered Item Revenue =
CALCULATE(
    SUM('Order Items'[price]),
    Orders[order_status] = "delivered"
)

Total Orders =
DISTINCTCOUNT(Orders[order_id])

Delivered Orders =
CALCULATE(
    DISTINCTCOUNT(Orders[order_id]),
    Orders[order_status] = "delivered"
)

Average Order Value =
DIVIDE([Delivered Item Revenue], [Delivered Orders])

Unique Customers =
CALCULATE(
    DISTINCTCOUNT(Orders[customer_unique_id]),
    Orders[order_status] = "delivered"
)

Average Review Score =
AVERAGE('Review Summary'[review_score])

Late Delivered Orders =
CALCULATE(DISTINCTCOUNT(Orders[order_id]), Orders[Late Flag] = TRUE())

Delivered Orders with Dates =
CALCULATE(
    DISTINCTCOUNT(Orders[order_id]),
    Orders[order_status] = "delivered",
    NOT(ISBLANK(Orders[order_delivered_customer_date])),
    NOT(ISBLANK(Orders[order_estimated_delivery_date]))
)

Delivery Delay % =
DIVIDE([Late Delivered Orders], [Delivered Orders with Dates])
```

Format revenue and AOV as decimal/currency without implying profit. Format `Delivery Delay %` as percentage and `Average Review Score` to two decimals. `Total Orders` includes all statuses; `Delivered Orders` is used for AOV and delivered-sales metrics.

For the repeat-customer visual, use the supplied `outputs/analysis_results/business_insights.csv` or `kpi_summary.csv` for the overall project value (3.00% repeat). For a dynamic visual, create an order-count-by-customer summary in Power Query by grouping delivered orders on `customer_unique_id`, count distinct `order_id`, then add a `Customer Type` column: `Repeat` if count > 1, otherwise `One-time`. Label that visual as whole-period unless you build it from a date-aware customer measure.

## 4. Build the three report pages

Create three pages using the page tabs at the bottom. Start with one visual at a time; drag fields into the visual's field wells.

### Page 1 — Executive Overview

- Add six Card visuals: Delivered Item Revenue, Total Orders, Unique Customers, Average Order Value, Average Review Score, Delivery Delay %.
- Add a Line chart: purchase timestamp (month) on X-axis; Delivered Item Revenue on Y-axis.
- Add a clustered column chart: purchase month on X-axis; Delivered Orders on Y-axis.
- Add a bar chart: English category on Y-axis; Delivered Item Revenue on X-axis. Sort descending; show top 10 if labels crowd.
- Add a bar chart: customer state on Y-axis; Delivered Item Revenue on X-axis; sort descending.
- Add slicers: purchase date, customer state, category, order status and seller.

### Page 2 — Customer & Product

- Add a donut or stacked bar for One-time versus Repeat customer counts from the grouped customer summary. Create it from Orders filtered to delivered first, grouped by `customer_unique_id`, then count distinct `order_id`.
- Add a bar chart for top customers using `customer_unique_id` and Delivered Item Revenue. Apply a Top N visual filter (10 by revenue) if desired.
- Add bar charts for top categories and top products by Delivered Item Revenue.
- Add a table with category, average review score and order count. If you build this from `Review Summary`, first create a distinct order-category table from Order Items + Products so each order/category appears once.

### Page 3 — Operations

- Add cards for average delivery time and late delivered orders. A simple average-delivery-time measure is `AVERAGEX(FILTER(Orders, Orders[order_status] = "delivered" && NOT(ISBLANK(Orders[order_delivered_customer_date])) && NOT(ISBLANK(Orders[order_estimated_delivery_date]))), DATEDIFF(Orders[order_purchase_timestamp], Orders[order_delivered_customer_date], DAY))`.
- Add a bar chart for delivery delay % by customer state.
- Add a seller table with seller ID/state, delivered item revenue, delivered orders and average review score (use a one-row-per-order review summary to avoid duplication).
- Add a bar chart for average review score by Late versus On-time group. Create the group using the same actual-vs-estimated date rule as Delivery Delay %.
- Add a bar chart of order count by order status.

Use clear titles, avoid 3D charts, keep a consistent color palette, and add a small note: “Revenue = delivered item price; excludes freight and costs.”

## 5. Check results, then save

1. Compare cards to the generated result files in `outputs/analysis_results/`: total orders **99,441**, delivered item revenue **13,221,498.11**, delivered orders **96,478**, unique delivered customers **93,358**, repeat share **3.00%**, average review score **4.09**, average delivery **12.56 days**, and late share **8.11%**. Minor differences can occur if a visual includes another status or a different review grain.
2. Click each slicer and confirm visuals respond without duplicated revenue. If a revenue value multiplies when adding reviews or payments, remove the raw many-to-many join and use the summarized table.
3. Save the report as `powerbi/ecommerce_sales_operations_analytics.pbix`.
4. Update the main README to say the dashboard is built only after the `.pbix` exists. Then optionally take screenshots of the three pages for your portfolio.

Microsoft's official guidance: [Create and manage relationships](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-create-and-manage-relationships) and [Create measures](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-measures).
