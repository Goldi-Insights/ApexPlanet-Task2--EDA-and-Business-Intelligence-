-- ============================================================
-- EDA & Business Intelligence - SQL Queries
-- Dataset: E-Commerce Orders (India) 2023-2024
-- Author: [Your Name]
-- ============================================================

-- -------------------------------------------------------
-- TABLE CREATION
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS ecommerce_orders (
    order_id        VARCHAR(30),
    order_date      DATE,
    delivery_date   DATE,
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(30),
    city            VARCHAR(50),
    region          VARCHAR(30),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(100),
    payment_mode    VARCHAR(30),
    quantity        INT,
    unit_price      DECIMAL(10,2),
    discount        DECIMAL(5,2),
    revenue         DECIMAL(10,2),
    profit          DECIMAL(10,2),
    shipping_cost   DECIMAL(8,2),
    order_status    VARCHAR(20),
    year            INT,
    month           INT
);

-- -------------------------------------------------------
-- DESCRIPTIVE STATISTICS
-- -------------------------------------------------------

-- Q0: Overall summary statistics
SELECT
    COUNT(*)                        AS total_orders,
    ROUND(SUM(revenue), 2)          AS total_revenue,
    ROUND(SUM(profit), 2)           AS total_profit,
    ROUND(AVG(revenue), 2)          AS avg_order_value,
    ROUND(AVG(discount)*100, 2)     AS avg_discount_pct,
    SUM(quantity)                   AS total_units_sold
FROM ecommerce_orders
WHERE order_status = 'Delivered';

-- -------------------------------------------------------
-- BUSINESS QUESTION 1:
-- What are the Top 5 Products by Total Revenue?
-- -------------------------------------------------------
SELECT
    product_name,
    category,
    COUNT(order_id)         AS total_orders,
    SUM(quantity)           AS units_sold,
    ROUND(SUM(revenue), 2)  AS total_revenue,
    ROUND(SUM(profit), 2)   AS total_profit
FROM ecommerce_orders
WHERE order_status = 'Delivered'
GROUP BY product_name, category
ORDER BY total_revenue DESC
LIMIT 5;

-- -------------------------------------------------------
-- BUSINESS QUESTION 2:
-- What is the Monthly Revenue Trend for 2023 and 2024?
-- -------------------------------------------------------
SELECT
    year,
    month,
    COUNT(order_id)         AS orders_count,
    ROUND(SUM(revenue), 2)  AS monthly_revenue,
    ROUND(SUM(profit), 2)   AS monthly_profit
FROM ecommerce_orders
WHERE order_status = 'Delivered'
GROUP BY year, month
ORDER BY year, month;

-- -------------------------------------------------------
-- BUSINESS QUESTION 3:
-- Which Category is Most Profitable?
-- -------------------------------------------------------
SELECT
    category,
    COUNT(order_id)                             AS total_orders,
    ROUND(SUM(revenue), 2)                      AS total_revenue,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit)/SUM(revenue)*100, 2)      AS profit_margin_pct
FROM ecommerce_orders
WHERE order_status = 'Delivered'
GROUP BY category
ORDER BY total_profit DESC;

-- -------------------------------------------------------
-- BUSINESS QUESTION 4:
-- Who are the Top 10 Customers by Revenue?
-- -------------------------------------------------------
SELECT
    customer_name,
    customer_id,
    COUNT(order_id)         AS total_orders,
    SUM(quantity)           AS total_units,
    ROUND(SUM(revenue), 2)  AS total_revenue,
    ROUND(SUM(profit), 2)   AS total_profit
FROM ecommerce_orders
WHERE order_status = 'Delivered'
GROUP BY customer_name, customer_id
ORDER BY total_revenue DESC
LIMIT 10;

-- -------------------------------------------------------
-- BUSINESS QUESTION 5:
-- How does Region-wise Sales Performance compare?
-- -------------------------------------------------------
SELECT
    region,
    COUNT(DISTINCT city)    AS cities_covered,
    COUNT(order_id)         AS total_orders,
    ROUND(SUM(revenue), 2)  AS total_revenue,
    ROUND(SUM(profit), 2)   AS total_profit,
    ROUND(AVG(revenue), 2)  AS avg_order_value
FROM ecommerce_orders
WHERE order_status = 'Delivered'
GROUP BY region
ORDER BY total_revenue DESC;

-- -------------------------------------------------------
-- BUSINESS QUESTION 6:
-- What is the Impact of Discount on Profit?
-- -------------------------------------------------------
SELECT
    CASE
        WHEN discount = 0           THEN 'No Discount'
        WHEN discount <= 0.10       THEN 'Low (1-10%)'
        WHEN discount <= 0.20       THEN 'Medium (11-20%)'
        ELSE                             'High (>20%)'
    END                             AS discount_bracket,
    COUNT(order_id)                 AS orders,
    ROUND(AVG(revenue), 2)          AS avg_revenue,
    ROUND(AVG(profit), 2)           AS avg_profit,
    ROUND(SUM(profit), 2)           AS total_profit
FROM ecommerce_orders
WHERE order_status = 'Delivered'
GROUP BY discount_bracket
ORDER BY avg_profit DESC;

-- -------------------------------------------------------
-- BUSINESS QUESTION 7:
-- What is the Most Popular Payment Mode by Segment?
-- -------------------------------------------------------
SELECT
    segment,
    payment_mode,
    COUNT(order_id)         AS order_count,
    ROUND(SUM(revenue), 2)  AS total_revenue
FROM ecommerce_orders
WHERE order_status = 'Delivered'
GROUP BY segment, payment_mode
ORDER BY segment, order_count DESC;

-- -------------------------------------------------------
-- BONUS: Return/Cancellation Rate by Category
-- -------------------------------------------------------
SELECT
    category,
    COUNT(order_id)                                         AS total_orders,
    SUM(CASE WHEN order_status='Returned' THEN 1 ELSE 0 END)    AS returns,
    SUM(CASE WHEN order_status='Cancelled' THEN 1 ELSE 0 END)   AS cancellations,
    ROUND(
        SUM(CASE WHEN order_status IN ('Returned','Cancelled') THEN 1 ELSE 0 END)
        * 100.0 / COUNT(order_id), 2
    )                                                       AS loss_rate_pct
FROM ecommerce_orders
GROUP BY category
ORDER BY loss_rate_pct DESC;
