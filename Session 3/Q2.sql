WITH cte AS (
    SELECT
        product_id,
        product_name,
        month_start,
        monthly_active_users,
        LAG(monthly_active_users, 1) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS p1,
        LAG(monthly_active_users, 2) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS p2,
        LAG(monthly_active_users, 3) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS p3,
        LEAD(monthly_active_users, 1) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS n1,
        LEAD(monthly_active_users, 2) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS n2,
        LEAD(monthly_active_users, 3) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS n3,
        LAG(month_start, 3) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS decline_start
    FROM product_engagement
),
turnaround AS (
    SELECT
        product_id,
        product_name,
        decline_start,
        month_start AS growth_resumed,
        monthly_active_users AS lowest_users,
        n3 AS peak_users
    FROM cte
    WHERE p3 > p2
      AND p2 > p1
      AND p1 > monthly_active_users
      AND monthly_active_users < n1
      AND n1 < n2
      AND n2 < n3
)
SELECT
    product_name,
    decline_start,
    growth_resumed,
    ROUND(
        (peak_users - lowest_users) * 1.0 / lowest_users,
        2
    ) AS growth_ratio
FROM turnaround;