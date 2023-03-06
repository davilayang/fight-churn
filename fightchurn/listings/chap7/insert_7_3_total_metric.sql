-- insert_7_3_total_metric

INSERT into metric_name values (%new_metric_id,'%new_metric_name')
ON CONFLICT DO NOTHING;

INSERT INTO metric (account_id,metric_time,metric_name_id,metric_value)

    SELECT 
        account_id, 
        metric_time, 
        %new_metric_id AS metric_name_id, 
        sum(metric_value) AS metric_total,
      FROM 
        metric AS m 
INNER JOIN 
        metric_name AS n 
        ON n.metric_name_id = m.metric_name_id
       AND n.metric_name IN (%metric_list)
     WHERE metric_time BETWEEN '%from_yyyy-mm-dd' AND '%to_yyyy-mm-dd'
  GROUP BY metric_time, account_id

ON CONFLICT DO NOTHING;

