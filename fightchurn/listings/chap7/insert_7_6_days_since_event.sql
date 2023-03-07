-- insert_7_6_days_since_event
-- calculate difference beween a given event type to form a new metric
-- e.g. day since new friend event

INSERT into metric_name values (%new_metric_id,concat('days_since_%event2measure' ))
ON CONFLICT DO NOTHING;

WITH date_vals AS (
  SELECT 
      i::date AS metric_date
    FROM 
      GENERATE_SERIES('%from_yyyy-mm-dd', '%to_yyyy-mm-dd', '7 day'::interval) AS i
),
last_event AS (
      SELECT 
          account_id, 
          metric_date, 
          MAX(event_time)::date AS last_date,
        FROM 
          event AS e 
  INNER JOIN date_vals AS d
          ON e.event_time::date <= metric_date
  INNER JOIN event_type AS t 
          ON t.event_type_id=e.event_type_id
       WHERE t.event_type_name='%event2measure'
    GROUP BY account_id, metric_date
    ORDER BY account_id, metric_date
)

INSERT INTO metric (account_id,metric_time,metric_name_id,metric_value)

    SELECT 
        account_id, 
        metric_date AS metric_time, 
        %new_metric_id AS metric_name_id,
        metric_date - last_date AS days_since_event, -- metic_value
      FROM 
        last_event

ON CONFLICT DO NOTHING;
