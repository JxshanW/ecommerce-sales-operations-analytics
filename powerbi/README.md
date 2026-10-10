# Power BI handoff

Use the model and measures in `dashboard_requirements.md`. Import source tables and create one-to-many relationships from dimensions to facts. Keep orders as the order-level fact for status/delivery, items for sales, and avoid joining payment or review detail directly to item detail without aggregation. Revenue should be item price; distinct order count should use `order_id`.

Power BI Dashboard

The Power BI report file is available here: 
https://drive.google.com/file/d/10H9NZmqjTrhbS-75xjB_MB-WCY7tCEFq/view?usp=sharing

Dashboard screenshots are available in the powerbi/screenshots folder.