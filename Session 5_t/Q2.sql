WITH trans AS (
    SELECT
        *,
        LAG(transaction_timestamp) OVER (
            PARTITION BY merchant_id, credit_card_id, amount
        ) AS prev_time
    FROM transactions
)

SELECT
    COUNT(*) AS payment_count
FROM trans
WHERE prev_time IS NOT NULL
  AND transaction_timestamp - prev_time <= INTERVAL '10 minutes';