WITH sent AS (
    SELECT
        date,
        user_id_sender,
        user_id_receiver
    FROM fb_friend_requests
    WHERE action = 'sent'
),
accepted AS (
    SELECT
        user_id_sender,
        user_id_receiver
    FROM fb_friend_requests
    WHERE action = 'accepted'
)
SELECT
    s.date,
    ROUND(
        COUNT(a.user_id_sender) * 1.0 /
        COUNT(*),
        2
    ) AS acceptance_rate
FROM sent s
LEFT JOIN accepted a
    ON s.user_id_sender = a.user_id_sender
   AND s.user_id_receiver = a.user_id_receiver
GROUP BY s.date
HAVING COUNT(a.user_id_sender) > 0
ORDER BY s.date;