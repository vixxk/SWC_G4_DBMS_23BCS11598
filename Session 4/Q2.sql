WITH valid_tasks AS (
    SELECT DISTINCT
        task_id,
        start_time,
        end_time
    FROM task_schedule
    WHERE start_time IS NOT NULL
      AND end_time IS NOT NULL
),
events AS (
    SELECT start_time AS event_time, 1 AS delta
    FROM valid_tasks

    UNION ALL

    SELECT end_time AS event_time, -1 AS delta
    FROM valid_tasks
),
cpu_usage AS (
    SELECT
        event_time,
        SUM(delta) OVER (
            ORDER BY event_time, delta
            ROWS UNBOUNDED PRECEDING
        ) AS running_tasks
    FROM events
)
SELECT MAX(running_tasks) AS min_cpus_required
FROM cpu_usage;