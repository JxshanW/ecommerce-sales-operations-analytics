# Data inventory and model

The source archive supplies these nine CSVs. Preserve source files as-is in `raw/`. Import identifiers as text, amounts as decimal numbers, counts as integers and timestamps as datetimes. Exact row counts, column counts, and exact-row duplicates are in `../outputs/analysis_results/data_profile.csv`; per-column missingness and inferred types are in `column_profile.csv`; declared-key duplicate checks are in `key_profile.csv`.

| File | Grain / key | Important links | Use |
|---|---|---|---|
| olist_orders_dataset.csv | One order / `order_id` | `customer_id` | Status, purchase and fulfillment dates |
| olist_order_items_dataset.csv | One item / (`order_id`,`order_item_id`) | `order_id`, `product_id`, `seller_id` | Item sales value and freight |
| olist_customers_dataset.csv | One order-customer / `customer_id` | `customer_unique_id` identifies a person across orders | State and repeat purchase analysis |
| olist_products_dataset.csv | One product / `product_id` | Category name | Category analysis |
| olist_sellers_dataset.csv | One seller / `seller_id` | Item seller | Seller performance |
| olist_order_payments_dataset.csv | One payment installment / (`order_id`,`payment_sequential`) | `order_id` | Payment methods and payment value |
| olist_order_reviews_dataset.csv | Review/order record / (`review_id`,`order_id`) | `order_id` | Review scores; 814 repeated `review_id` values occur across rows, while the composite key is unique |
| olist_geolocation_dataset.csv | ZIP location observations; ZIP prefix repeats | ZIP prefix + state/city for summarized lookup | Retained, not joined directly to facts |
| product_category_name_translation.csv | One category translation / category name | Product category | English labels |

## Relationships and join cautions

`orders.customer_id` joins customers. `order_items.order_id` joins orders; items join products and sellers by their IDs. Payments and reviews join by order. Items, payment installments and review records are one-to-many: aggregate each to the desired grain before joining child tables together. Otherwise revenue or order totals can be duplicated. Customer repeat behavior uses `customer_unique_id`, since `customer_id` is assigned at the order-customer record level.

Geolocation contains repeated ZIP prefixes. A raw ZIP join can duplicate customers/sellers; do not use it without first selecting a documented representative location and checking state consistency. State analysis in this project uses customer/seller state columns.

## Data quality and metric decisions

Measured inventory: orders 99,441 x 8; items 112,650 x 7; customers 99,441 x 5; products 32,951 x 9; sellers 3,095 x 4; payments 103,886 x 5; reviews 99,224 x 7; geolocation 1,000,163 x 5; translations 71 x 2. There are 4,908 missing order cells, 2,448 missing product cells, and 145,903 missing review cells (mostly optional comment text). The geolocation file has 261,831 exact duplicate rows. Check declared keys in the generated key profile; `review_id` alone repeats, but (`review_id`,`order_id`) is unique in this extract. Null delivery dates are structurally expected for non-delivered orders. Category names can be missing and are grouped as `unknown`. Do not drop repeated geolocation observations arbitrarily. Revenue is item `price` and excludes freight. Payment value can differ from item value because it represents payment transactions/installments; do not substitute it for item revenue. No reliable product/seller costs are present, so profit and margin are unavailable.
