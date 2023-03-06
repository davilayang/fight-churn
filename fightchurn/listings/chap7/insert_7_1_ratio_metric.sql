-- insert_7_1_ratio_metric

INSERT into metric_name values (%new_metric_id,concat('%new_metric_name'))
ON CONFLICT DO NOTHING;

-- numerator metric
WITH num_metric AS (
            SELECT
                    account_id,
                    metric_time,
                    metric_value AS num_value
                FROM
                    metric AS m
    INNER JOIN metric_name AS n
                     ON n.metric_name_id = m.metric_name_id
                  AND n.metric_name = '%num_metric'
                  AND metric_time BETWEEN '%from_yyyy-mm-dd' AND '%to_yyyy-mm-dd'
), -- denominator metric
den_metric AS (
            SELECT
                    account_id,
                    metric_time,
                    metric_value AS den_value
              FROM
                    metric AS m
    INNER JOIN metric_name AS n
                    ON n.metric_name_id=m.metric_name_id
               AND n.metric_name = '%den_metric'
                 AND metric_time BETWEEN '%from_yyyy-mm-dd' AND '%to_yyyy-mm-dd'
)

INSERT INTO metric (account_id,metric_time,metric_name_id,metric_value)

                 SELECT
                         d.account_id,
                         d.metric_time,
                         %new_metric_id,
          CASE WHEN den_value > 0
                     THEN coalesce(num_value,0.0)/den_value
                     ELSE 0
                     END AS metric_value
                     FROM den_metric AS d
LEFT OUTER JOIN num_metric AS n
                       ON n.account_id = d.account_id
                       AND n.metric_time = d.metric_time

ON CONFLICT DO NOTHING;
