
-- =========================================
-- Query 1: Top 50 producers by revenue in 2021
-- =========================================

SELECT
    p.producer_id,
    SUM(pi.item_quantity * pi.purchase_value) AS total_revenue
FROM purchase p
JOIN product_item pi
    ON p.prod_item_id = pi.prod_item_id
    AND p.prod_item_partition = pi.prod_item_partition
WHERE year(p.order_date) = 2021
    AND p.release_date IS NOT NULL
GROUP BY p.producer_id
ORDER BY total_revenue DESC
LIMIT 50;

-- =========================================
-- Query 2: Top 2 products by revenue per producer
-- =========================================

WITH product_revenue AS (
    SELECT
        p.producer_id,
        pi.product_id,
        SUM(pi.item_quantity * pi.purchase_value) AS product_revenue
    FROM purchase p
    JOIN product_item pi
        ON p.prod_item_id = pi.prod_item_id
        AND p.prod_item_partition = pi.prod_item_partition
    WHERE p.release_date IS NOT NULL
    GROUP BY p.producer_id, pi.product_id
),
ranked_products AS (
    SELECT
        producer_id,
        product_id,
        product_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY producer_id
            ORDER BY product_revenue DESC
        ) AS rn
    FROM product_revenue
)
SELECT
    producer_id,
    product_id,
    product_revenue
FROM ranked_products
WHERE rn <= 2
ORDER BY producer_id, product_revenue DESC;
