-- insert_7_8_tenure_scaled_events_per_month
-- similar to 7.7

INSERT INTO metric_name VALUES (%new_metric_id,'%event2measure_%desc_periodday_avg_%obs_periodday_obs_scaled')
ON CONFLICT DO NOTHING;


INSERT INTO metric (account_id,metric_time,metric_name_id,metric_value)

    SELECT 
        m.account_id, 
        metric_time, 
        %new_metric_id AS metric_name_id,
        (%desc_period / least(%obs_period, m.metric_value)) * count(*) AS metric_value,
      FROM 
        event AS e 
INNER JOIN 
        metric AS m
        ON m.account_id = e.account_id
       AND event_time <= metric_time
       AND event_time >  metric_time-interval '%obs_period days'
INNER JOIN 
        event_type AS t 
        ON t.event_type_id=e.event_type_id
INNER JOIN 
        metric_name AS n 
        ON m.metric_name_id = n.metric_name_id
     WHERE t.event_type_name='%event2measure'
       AND n.metric_name='account_tenure'
       AND metric_value >= %min_tenure
  GROUP BY m.account_id, metric_time, metric_value    
  ORDER BY m.account_id, metric_time, metric_value

ON CONFLICT DO NOTHING;
