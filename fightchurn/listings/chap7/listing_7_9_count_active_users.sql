-- listing_7_9_count_active_users
-- count distinct users along the given date

WITH date_vals AS (
    SELECT 
        i::timestamp AS metric_date
      FROM 
        GENERATE_SERIES('%from_yyyy-mm-dd', '%to_yyyy-mm-dd', '7 day'::interval) AS i
)

    SELECT 
        account_id, 
        metric_date, 
        COUNT(DISTINCT user_id) AS n_distinct_users,
      FROM 
        event AS e 
INNER JOIN 
        date_vals AS d
        ON e.event_time <= metric_date
       AND e.event_time > metric_date - interval '%obs_period days'
  GROUP BY account_id, metric_date
  ORDER BY metric_date, account_id;
