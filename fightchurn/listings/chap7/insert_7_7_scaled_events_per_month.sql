-- insert_7_7_scaled_events_per_month
-- ??

INSERT into metric_name values (%new_metric_id,'%event2measure_%desc_periodday_avg_%obs_periodday_obs')
ON CONFLICT DO NOTHING;

WITH date_vals AS (
    SELECT 
        i::timestamp AS metric_date 
      FROM 
        GENERATE_SERIES('%from_yyyy-mm-dd', '%to_yyyy-mm-dd', '7 day'::interval) AS i
)

INSERT INTO metric (account_id,metric_time,metric_name_id,metric_value)

    SELECT 
        account_id, 
        metric_date, 
        %new_metric_id AS metric_name_id,
        ((%desc_period)::float / (%obs_period)::float) * COUNT(*) AS metric_value,
      FROM 
        event AS e 
INNER JOIN 
        date_vals AS d
        ON e.event_time <= metric_date 
       AND e.event_time > metric_date - interval '%obs_period days'
INNER JOIN 
        event_type AS t 
        ON t.event_type_id=e.event_type_id
     WHERE t.event_type_name='%event2measure'
  GROUP BY account_id, metric_date
  ORDER BY metric_date, account_id

ON CONFLICT DO NOTHING;
