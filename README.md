# E-Commerce Sales & Operations Analytics

Portfolio project using the public Olist Brazilian E-Commerce dataset. The analysis covers sales value, customers, product categories, sellers, delivery, payments and reviews. Revenue means the sum of item prices; it is not profit.

## Project overview

The business question is how sales and fulfillment performance vary across time, products, customers and Brazilian states. SQL is the main analysis tool. Python supports data checks and charts, Excel provides a summary workbook, and the Power BI folder contains a practical dashboard plan.

## Dataset and scope

Nine supplied CSVs are retained in `data/raw`. Core analysis uses orders, order items, customers, products, sellers, payments, reviews and the category translation. Geolocation is retained for reference but is not joined at row level: its ZIP prefixes are not unique and a direct join would multiply records. See `data/README.md` for table details and profiling results.

Item revenue is `SUM(order_items.price)` and excludes freight and payment adjustments. Order count is distinct `order_id`. Delivered-order measures are restricted to orders with status `delivered`; canceled/unavailable orders are excluded from realized item revenue and fulfillment durations. Customer identity uses `customer_unique_id`, not the per-order `customer_id`.

## Data model

```text
customers (customer_id) 1 ── * orders (order_id) 1 ── * order_items
                                      │                       ├── products ── category translation
                                      │                       └── sellers
                                      ├── * payments
                                      └── * reviews
```

Orders are one row per order. Items, payments and reviews can have multiple rows per order. Aggregate each child table to order level before joining it to another child table to avoid fan-out.

## Tools and workflow

- SQL: exploration and business analysis, including CTEs and window functions.
- Python: pandas data checks, date handling, joins and basic EDA (`python/ecommerce_eda.ipynb`).
- Excel: KPI summary and supporting analysis sheets (`excel/ecommerce_analysis.xlsx`).
- Power BI: three-page dashboard specification (`powerbi/dashboard_requirements.md`).

## Cleaning and metric notes

Timestamp columns are parsed as datetimes. Missing delivery timestamps are expected for non-delivered orders and are excluded from delivery-duration calculations. Product category blanks are labeled `unknown` for grouping. Review comments are optional text and are not required for score analysis. The source includes a geolocation table with repeated ZIP prefixes; it should be summarized before any geographic enrichment.

The source column `order_delivered_customer_date` is compared with `order_estimated_delivery_date`. Delay means delivered after estimate; it does not measure carrier-only delay. Monthly sales use purchase month and delivered orders when analyzing realized sales. See the SQL comments for each query's denominator.

## KPIs and key insights

From the supplied data, delivered item revenue is **13,221,498.11** across **96,478** delivered orders, with **137.04** average order value. There are **93,358** delivered customer identities and **2,801** repeat customers (**3.00%**). Average order-level review score is **4.09/5**; average delivery time is **12.56 days**; **8.11%** of delivered orders arrived after the estimate.

Health & beauty led category revenue (**1,233,131.72**), and SP led customer-state revenue (**5,067,633.16**). Late delivered orders averaged **2.57/5** in reviews compared with **4.29/5** for orders delivered on or before the estimate. This is an association, not proof of cause. More detail and recommendations are in `PROJECT_DOCUMENTATION.md` and `outputs/analysis_results/business_insights.csv`. No cost data is supplied, so the project does not report profit or margin.

## How to run

1. Keep the CSVs in `data/raw`.
2. Install notebook libraries with `pip install -r requirements.txt`.
3. Run `python build_outputs.py` from this project folder to regenerate the profile summaries, KPI output, notebook, and Excel workbook.
4. Open the notebook and run cells from top to bottom. It uses pandas, numpy, matplotlib and seaborn.
5. Run SQL files in order in PostgreSQL. `data/README.md` describes the recommended import types and keys.
6. Open the workbook in Excel. It contains formula-based KPIs and charts; use Excel's normal recalculation if formulas initially appear blank in another viewer.
7. Open the Power BI dashboard file from the link given below on my gooogle drive.

https://drive.google.com/file/d/10H9NZmqjTrhbS-75xjB_MB-WCY7tCEFq/view?usp=sharing

## Skills demonstrated

Data profiling, relational joins, SQL aggregation, CTEs, window functions, KPI definition, pandas EDA, charting, spreadsheet formulas, dashboard planning and business recommendations.

## Project structure

See the folders in this repository. The original CSV files are preserved in `data/raw` so results can be reproduced.


Power BI Dashboard

The Power BI report file is available here: 
https://drive.google.com/file/d/10H9NZmqjTrhbS-75xjB_MB-WCY7tCEFq/view?usp=sharing

Dashboard screenshots are available in the powerbi/screenshots folder.