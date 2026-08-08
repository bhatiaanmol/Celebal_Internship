SELECT
    p.category,
    ROUND(SUM(
        oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0)
    ), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;



SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(
        oi.quantity * oi.unit_price *
        (1 - oi.discount_percent / 100.0)
    ), 2) AS total_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_order_value DESC
LIMIT 10;


SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS order_count
FROM orders
WHERE date(order_date) >= date(
    (SELECT MAX(order_date) FROM orders),
    '-12 months'
)
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;


SELECT
    c.customer_id,
    c.customer_name
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(
    CASE
        WHEN o.status = 'DELIVERED' THEN 1
        ELSE 0
    END
) = 0;



SELECT
    p.product_id,
    p.product_name,
    SUM(CASE
        WHEN oi.quantity > 0 THEN oi.quantity
        ELSE 0
    END) AS purchased_quantity,
    SUM(CASE
        WHEN oi.quantity < 0 THEN ABS(oi.quantity)
        ELSE 0
    END) AS returned_quantity
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING returned_quantity > purchased_quantity
ORDER BY returned_quantity DESC;



SELECT
    p.category,
    SUM(
        CASE
            WHEN oi.quantity < 0 THEN ABS(oi.quantity)
            ELSE 0
        END
    ) AS returned_items,
    SUM(ABS(oi.quantity)) AS total_items,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN oi.quantity < 0 THEN ABS(oi.quantity)
                ELSE 0
            END
        ) / SUM(ABS(oi.quantity)),
        2
    ) AS return_rate_percent
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY return_rate_percent DESC;


WITH daily_sales AS (
    SELECT
        o.region_code,
        DATE(o.order_date) AS order_date,
        SUM(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ) AS daily_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.region_code, DATE(o.order_date)
)

SELECT
    region_code,
    order_date,
    ROUND(daily_revenue, 2) AS daily_revenue,
    ROUND(
        SUM(daily_revenue) OVER (
            PARTITION BY region_code
            ORDER BY order_date
        ), 2
    ) AS running_total
FROM daily_sales
ORDER BY region_code, order_date;



WITH product_revenue AS (
    SELECT
        p.category,
        p.product_name,
        SUM(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ) AS total_revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
)

SELECT
    category,
    product_name,
    ROUND(total_revenue, 2) AS total_revenue,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY total_revenue DESC
    ) AS rank_in_category
FROM product_revenue
ORDER BY category, rank_in_category;


WITH order_gaps AS (
    SELECT
        customer_id,
        DATE(order_date) AS order_date,
        LAG(DATE(order_date)) OVER (
            PARTITION BY customer_id
            ORDER BY DATE(order_date)
        ) AS previous_order_date
    FROM orders
    WHERE customer_id IS NOT NULL
),

gap_days AS (
    SELECT
        customer_id,
        order_date,
        previous_order_date,
        CAST(
            julianday(order_date) - julianday(previous_order_date)
            AS INTEGER
        ) AS days_gap
    FROM order_gaps
)

SELECT
    customer_id,
    order_date,
    previous_order_date,
    days_gap,
    CASE
        WHEN AVG(days_gap) OVER (
            PARTITION BY customer_id
        ) > 30
        THEN 'At Risk'
        ELSE 'Active'
    END AS customer_status
FROM gap_days
ORDER BY customer_id, order_date;



WITH monthly_customer_revenue AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        o.customer_id,
        SUM(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY
        strftime('%Y-%m', o.order_date),
        o.customer_id
),

customer_segments AS (
    SELECT
        month,
        customer_id,
        monthly_revenue,
        CASE
            WHEN monthly_revenue > 10000 THEN 'High'
            WHEN monthly_revenue >= 5000 THEN 'Medium'
            ELSE 'Low'
        END AS customer_segment
    FROM monthly_customer_revenue
)

SELECT
    month,
    customer_segment,
    COUNT(*) AS customer_count
FROM customer_segments
GROUP BY month, customer_segment
ORDER BY month, customer_segment;



WITH customer_value AS (
    SELECT
        o.customer_id,
        SUM(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ) AS total_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY o.customer_id
),

ranked AS (
    SELECT
        customer_id,
        total_value,
        NTILE(4) OVER (
            ORDER BY total_value DESC
        ) AS quartile
    FROM customer_value
)

SELECT
    customer_id,
    ROUND(total_value, 2) AS total_value,
    quartile,
    CASE
        WHEN quartile = 1 THEN 'Platinum'
        WHEN quartile = 2 THEN 'Gold'
        WHEN quartile = 3 THEN 'Silver'
        ELSE 'Bronze'
    END AS quartile_label
FROM ranked
ORDER BY total_value DESC;



WITH monthly_revenue AS (
    SELECT
        CAST(strftime('%Y', o.order_date) AS INTEGER) AS year,
        CAST(strftime('%m', o.order_date) AS INTEGER) AS month,
        SUM(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY year, month
)

SELECT
    current.year,
    current.month,
    ROUND(current.revenue, 2) AS revenue,
    ROUND(previous.revenue, 2) AS prev_year_revenue,
    CASE
        WHEN previous.revenue IS NULL OR previous.revenue = 0 THEN NULL
        ELSE ROUND(
            ((current.revenue - previous.revenue) / previous.revenue) * 100,
            2
        )
    END AS yoy_growth_percent
FROM monthly_revenue current
LEFT JOIN monthly_revenue previous
    ON current.month = previous.month
    AND current.year = previous.year + 1
ORDER BY current.year, current.month;



WITH customer_categories AS (
    SELECT
        o.customer_id,
        p.category,
        DATE(o.order_date) AS order_date,
        FIRST_VALUE(p.category) OVER (
            PARTITION BY o.customer_id
            ORDER BY DATE(o.order_date)
        ) AS first_category,
        FIRST_VALUE(p.category) OVER (
            PARTITION BY o.customer_id
            ORDER BY DATE(o.order_date) DESC
        ) AS recent_category
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.customer_id IS NOT NULL
)

SELECT DISTINCT
    customer_id,
    first_category,
    recent_category,
    CASE
        WHEN first_category <> recent_category THEN 'Yes'
        ELSE 'No'
    END AS category_shift
FROM customer_categories
ORDER BY customer_id;



WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(
            oi.quantity * oi.unit_price *
            (1 - oi.discount_percent / 100.0)
        ) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY o.customer_id
)

SELECT
    customer_id,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue DESC
        ), 2
    ) AS cumulative_revenue,

    ROUND(
        100.0 * SUM(revenue) OVER (
            ORDER BY revenue DESC
        ) / SUM(revenue) OVER (),
        2
    ) AS cumulative_percent

FROM customer_revenue
ORDER BY revenue DESC;



WITH customer_cohort AS (
    SELECT
        customer_id,
        strftime('%Y-%m', registration_date) AS cohort_month
    FROM customers
),

customer_orders AS (
    SELECT
        o.customer_id,
        strftime('%Y-%m', o.order_date) AS order_month
    FROM orders o
    WHERE o.customer_id IS NOT NULL
),

cohort_orders AS (
    SELECT
        c.customer_id,
        c.cohort_month,
        o.order_month,
        (
            (CAST(strftime('%Y', o.order_month || '-01') AS INTEGER) -
             CAST(strftime('%Y', c.cohort_month || '-01') AS INTEGER)) * 12
            +
            (CAST(strftime('%m', o.order_month || '-01') AS INTEGER) -
             CAST(strftime('%m', c.cohort_month || '-01') AS INTEGER))
        ) AS month_number
    FROM customer_cohort c
    JOIN customer_orders o
        ON c.customer_id = o.customer_id
),

cohort_summary AS (
    SELECT
        cohort_month,

        COUNT(DISTINCT CASE
            WHEN month_number = 0 THEN customer_id
        END) AS month_0,

        COUNT(DISTINCT CASE
            WHEN month_number = 1 THEN customer_id
        END) AS month_1,

        COUNT(DISTINCT CASE
            WHEN month_number = 2 THEN customer_id
        END) AS month_2,

        COUNT(DISTINCT CASE
            WHEN month_number = 3 THEN customer_id
        END) AS month_3

    FROM cohort_orders
    WHERE month_number BETWEEN 0 AND 3
    GROUP BY cohort_month
)

SELECT
    cohort_month,
    month_0,
    month_1,
    month_2,
    month_3,

    ROUND(100.0 * month_1 / NULLIF(month_0, 0), 2) AS month_1_retention,
    ROUND(100.0 * month_2 / NULLIF(month_0, 0), 2) AS month_2_retention,
    ROUND(100.0 * month_3 / NULLIF(month_0, 0), 2) AS month_3_retention

FROM cohort_summary
ORDER BY cohort_month;




SELECT
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
    AND oi1.product_id < oi2.product_id
JOIN products p1
    ON oi1.product_id = p1.product_id
JOIN products p2
    ON oi2.product_id = p2.product_id
GROUP BY
    p1.product_name,
    p2.product_name
ORDER BY times_bought_together DESC;