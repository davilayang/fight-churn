-- insert_7_4_percent_change_metric

INSERT into metric_name values (%new_metric_id,'%new_metric_name')
ON CONFLICT DO NOTHING;

WITH end_metric AS (
    SELECT 
        account_id, 
        metric_time, 
        metric_value AS end_value,
      FROM metric AS m 
INNER JOIN metric_name n 
        ON n.metric_name_id = m.metric_name_id
       AND n.metric_name = '%metric2measure'
       AND metric_time BETWEEN '%from_yyyy-mm-dd' AND '%to_yyyy-mm-dd'
), 
start_metric AS (
    SELECT account_id, metric_time, metric_value AS start_value
      FROM metric AS m 
INNER JOIN metric_name AS n 
        ON n.metric_name_id = m.metric_name_id
       AND n.metric_name = '%metric2measure'
       AND metric_time BETWEEN ('%from_yyyy-mm-dd'::timestamp - interval '%period_weeks week')
       AND ('%to_yyyy-mm-dd'::timestamp - interval '%period_weeks week')
)

INSERT INTO metric (account_id,metric_time,metric_name_id,metric_value)

         SELECT 
             s.account_id,  
             s.metric_time + interval '%period_weeks week', %new_metric_id,
             COALESCE(end_value,0.0)/start_value - 1.0,
           FROM 
             start_metric s 
LEFT OUTER JOIN end_metric e
             ON s.account_id=e.account_id
            AND e.metric_time=(s.metric_time + interval '%period_weeks week')
          WHERE start_value > 0
ON CONFLICT DO NOTHING;

