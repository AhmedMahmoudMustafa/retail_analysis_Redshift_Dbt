# 🏩 Retail Analytics Data Modeling with dbt & Amazon Redshift

This project demonstrates a complete data modeling pipeline using **Amazon Redshift Serverless**, **dbt**, and SQL-based transformation to generate insightful data marts for downstream analytics.

---

##  Project Overview

We simulate a retail business scenario where raw sales and dimension data are transformed into business-friendly data marts. The marts support use cases such as:

* Customer segmentation
* Store-level performance analysis
* Monthly sales tracking

---

## 📊 Tech Stack

| Tool                  | Purpose                         |
| --------------------- | ------------------------------- |
| Amazon Redshift       | Cloud data warehouse            |
| dbt (Data Build Tool) | SQL-based data modeling and ELT |
| SQL                   | Core transformation logic       |

---

## 📆 Schema Overview

All data resides in a schema named `retail`.

### Raw Tables

* `dim_stores`  - Store metadata
* `dim_products` - Product details
* `dim_time` - Date dimension
* `dim_customer` - Customer dimension
* `dim_employees` - employees dimension
* `fact_sales` - Transactional sales data
* `fact_inventory` - tracking the stock level

### dbt Staging Models (Views)

* `stg_retail__dim_stores`
* `stg_retail__dim_products`
* `stg_retail__dim_time`
* `stg_retail__dim_customer`
* `stg_retail__dim_employees`
* `stg_retail__fact_sales`
* `stg_retail__fact_inventory`

### dbt Marts (Tables)

* `monthly_sales` - Monthly revenue & quantity sold
* `customer_segmentation` - RFM and volume-based segments
* `store_sales` - Store/category-wise sales metrics

---

## 👩‍💼 Project Flow

### 1. Create Redshift Serverless Environment

* Launch Redshift Serverless
* Enable **public accessibility**
* Add your IP to the VPC security group inbound rules
* Create schema `retail`

### 2. Create Tables and Insert Fake Data

Run manual SQL scripts to:

* Create the 7 base tables
* Insert realistic but fabricated data into them

### 3. Set Up dbt Project


* Configure `profiles.yml` to connect to Redshift
* Create model directories: `staging/`, `marts/customer/`, `marts/sales/`, `marts/store/`

### 4. Build Staging Models (Views)

Each raw table has a staging model that:

* Selects only needed columns
* Applies naming and type consistency

### 5. Build Marts (Tables)

Defined as `table` materializations:

**`mart_monthly_sales.sql`**

* Aggregates total revenue, quantity sold, and order count per month

**`mart_customer_segmentation.sql`**

* Computes RFM (Recency, Frequency, Monetary) scores
* Labels customers into segments like Champion, At Risk, Lost

**`mart_store_performance.sql`**

* Calculates store performance by category, year, and month
* Metrics: number of sales, total revenue, avg. order value


## 📊 Example Queries

Top stores by revenue:

```sql
SELECT store_name, SUM(total_revenue)
FROM retail.store_sales
GROUP BY store_name
ORDER BY SUM(total_revenue) DESC
LIMIT 5;
```

Customer segment distribution:

```sql
SELECT customer_segment_rfm, COUNT(*)
FROM retail.customer_segmentation
GROUP BY customer_segment_rfm;
```

