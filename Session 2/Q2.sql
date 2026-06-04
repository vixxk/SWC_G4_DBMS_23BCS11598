WITH max_date AS (
    SELECT MAX(event_timestamp::date) AS max_dt
    FROM search_events
),
searches AS (
    SELECT
        se.event_id,
        se.user_id,
        se.session_id,
        se.event_timestamp
    FROM search_events se
    WHERE se.event_type = 'search'
),
search_results AS (
    SELECT
        s.event_id,
        s.user_id,
        MIN(c.event_timestamp) AS first_click_time
    FROM searches s
    LEFT JOIN search_events c
        ON c.user_id = s.user_id
       AND c.session_id = s.session_id
       AND c.event_type = 'click'
       AND c.event_timestamp > s.event_timestamp
    GROUP BY s.event_id, s.user_id
)
SELECT
    CASE
        WHEN a.registration_date >= md.max_dt - INTERVAL '30 days' THEN 'new'
        ELSE 'existing'
    END AS user_segment,
    COUNT(*) AS total_searches,
    COUNT(*) FILTER (
        WHERE sr.first_click_time IS NOT NULL
          AND sr.first_click_time <= (
              SELECT event_timestamp
              FROM searches s
              WHERE s.event_id = sr.event_id
          ) + INTERVAL '30 seconds'
    ) AS successful_searches,
    ROUND(
        COUNT(*) FILTER (
            WHERE sr.first_click_time IS NOT NULL
              AND sr.first_click_time <= (
                  SELECT event_timestamp
                  FROM searches s
                  WHERE s.event_id = sr.event_id
              ) + INTERVAL '30 seconds'
        ) * 100.0 / COUNT(*),
        2
    ) AS success_rate
FROM search_results sr
JOIN accounts a
    ON a.user_id = sr.user_id
CROSS JOIN max_date md
GROUP BY 1
ORDER BY 1;