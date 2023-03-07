-- insert_7_4_percent_change_metric
-- caculcate the percentage change of a given metric to form a new metric
-- e.g. newfriend_per_month to new_friends_pct_change (comparing with previous period)

INSERT into metric_name values (%new_metric_id,'%new_metric_name')
ON CONFLICT DO NOTHING;

WITH end_metric AS (
    SELECT 
        account_id, 
        metric_time, 
        metric_value AS end_value,
      FROM metric AS m 
INNER JOIN metric_name AS n 
        ON n.metric_name_id = m.metric_name_id
       AND n.metric_name = '%metric2measure'
       AND metric_time BETWEEN '%from_yyyy-mm-dd' AND '%to_yyyy-mm-dd'
), 
start_metric AS (
    SELECT 
        account_id, 
        metric_time, 
        metric_value AS start_value
      FROM metric AS m 
INNER JOIN metric_name AS n 
        ON n.metric_name_id = m.metric_name_id
       AND n.metric_name = '%metric2measure'
       AND metric_time BETWEEN ('%from_yyyy-mm-dd'::timestamp - interval '%period_weeks week')
       AND ('%to_yyyy-mm-dd'::timestamp - interval '%period_weeks week')
)

INSERT INTO metric (account_id,metric_time,metric_name_id,metric_value)

          SELECT 
              s.account_id AS account_id,  
              s.metric_time + interval '%period_weeks week' AS metric_name, 
              %new_metric_id AS metric_name_id,
              COALESCE(end_value,0.0) / start_value - 1.0 AS metric_value,
            FROM 
              start_metric AS s 
 LEFT OUTER JOIN end_metric AS e
              ON s.account_id = e.account_id
             AND e.metric_time = (s.metric_time + interval '%period_weeks week')
           WHERE start_value > 0
 
ON CONFLICT DO NOTHING;

