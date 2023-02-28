-- listing_3_3_count_metric_insert.sql

WITH date_vals AS (
  SELECT
      i::timestamp AS metric_date
    FROM
      generate_series('%from_yyyy-mm-dd', '%to_yyyy-mm-dd', '7 day'::interval) AS i
)
INSERT INTO metric (account_id,metric_time,metric_name_id,metric_value)
    SELECT
        account_id,
        metric_date,
        %new_metric_id,
        count(*) AS metric_value
      FROM event AS e
INNER JOIN date_vals AS d
        ON e.event_time < metric_date
       AND e.event_time >= metric_date - interval '28 day'
INNER JOIN event_type AS t
        ON t.event_type_id=e.event_type_id
    WHERE t.event_type_name='%event2measure'
 GROUP BY account_id, metric_date
       ON CONFLICT DO NOTHING;
