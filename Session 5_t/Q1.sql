WITH u AS (
SELECT DISTINCT user_id,
DATE_TRUNC('month', event_date) AS month
FROM user_actions
)

SELECT 
EXTRACT(MONTH FROM u1.month) AS month,
COUNT(DISTINCT u1.user_id) AS monthly_active_users
FROM u AS u1
JOIN u AS u2
ON u1.month = u2.month + INTERVAL '1 MONTH' 
  AND u1.user_id = u2.user_id
GROUP BY u1.month
ORDER BY u1.month DESC
LIMIT 1;