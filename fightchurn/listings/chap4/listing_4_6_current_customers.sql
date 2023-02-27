WITH metric_date AS(
    SELECT MAX(metric_time) AS last_metric_time FROM metric
)

    SELECT 
        m.account_id, 
        d.last_metric_time,
        SUM(CASE WHEN metric_name_id=0 THEN metric_value ELSE 0 END) AS like_per_month,
        SUM(CASE WHEN metric_name_id=1 THEN metric_value ELSE 0 END) AS newfriend_per_month,
        SUM(CASE WHEN metric_name_id=2 THEN metric_value ELSE 0 END) AS post_per_month,
        SUM(CASE WHEN metric_name_id=3 THEN metric_value ELSE 0 END) AS adview_feed_per_month,
        SUM(CASE WHEN metric_name_id=4 THEN metric_value ELSE 0 END) AS dislike_per_month,
        SUM(CASE WHEN metric_name_id=5 THEN metric_value ELSE 0 END) AS unfriend_per_month,
        SUM(CASE WHEN metric_name_id=6 THEN metric_value ELSE 0 END) AS message_per_month,
        SUM(CASE WHEN metric_name_id=7 THEN metric_value ELSE 0 END) AS reply_per_month,
        SUM(CASE WHEN metric_name_id=8 THEN metric_value ELSE 0 END) AS account_tenure
      FROM metric AS m 
INNER JOIN metric_date AS d 
        ON m.metric_time = d.last_metric_time
INNER JOIN subscription AS s 
        ON m.account_id = s.account_id
     WHERE s.start_date <= d.last_metric_time
       AND (s.end_date >= d.last_metric_time OR s.end_date IS null)
  GROUP BY m.account_id, d.last_metric_time
  ORDER BY m.account_id
