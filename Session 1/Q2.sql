WITH RECURSIVE dates AS (
    SELECT DATE '2025-04-15' AS transaction_date
    UNION ALL
    SELECT transaction_date + INTERVAL '1 day'
    FROM dates
    WHERE transaction_date < DATE '2025-04-28'
),
purchases AS (
    SELECT
        transaction_id,
        transaction_date,
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
      AND country = 'US'
      AND status = 'completed'
      AND type = 'purchase'
      AND transaction_date BETWEEN '2025-04-15' AND '2025-04-28'
),
daily_txns AS (
    SELECT
        transaction_date,
        amount AS revenue
    FROM purchases

    UNION ALL

    SELECT
        r.transaction_date,
        -r.amount AS revenue
    FROM product_sales r
    JOIN purchases p
      ON r.original_transaction_id = p.transaction_id
    WHERE r.type = 'refund'
      AND r.status = 'completed'
)
SELECT
    d.transaction_date,
    COALESCE(SUM(t.revenue), 0) AS daily_net_revenue
FROM dates d
LEFT JOIN daily_txns t
    ON d.transaction_date = t.transaction_date
GROUP BY d.transaction_date
ORDER BY d.transaction_date;