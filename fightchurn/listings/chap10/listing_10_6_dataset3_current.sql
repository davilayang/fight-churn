WITH metric_date AS (
    SELECT 
        MAX(metric_time) AS last_metric_time 
      FROM metric
),
account_tenures AS (
    SELECT 
        account_id, 
        metric_value AS account_tenure
      FROM 
        metric AS m 
INNER JOIN 
        metric_date 
        ON metric_time =last_metric_time
    WHERE metric_name_id = 8
      AND metric_value >= 14
)

    SELECT 
        s.account_id, 
        d.last_metric_time AS observation_date,
        a.channel, 
        a.country, 
        DATE_PART('day', d.last_metric_time::timestamp - a.date_of_birth::timestamp)::float/365.0 AS customer_age,
        SUM(CASE WHEN metric_name_id=0 THEN metric_value ELSE 0 END) AS like_per_month,
        SUM(CASE WHEN metric_name_id=1 THEN metric_value ELSE 0 END) AS newfriend_per_month,
        SUM(CASE WHEN metric_name_id=2 THEN metric_value ELSE 0 END) AS post_per_month,
        SUM(CASE WHEN metric_name_id=3 THEN metric_value ELSE 0 END) AS adview_per_month,
        SUM(CASE WHEN metric_name_id=4 THEN metric_value ELSE 0 END) AS dislike_per_month,
        SUM(CASE WHEN metric_name_id=34 THEN metric_value ELSE 0 END) AS unfriend_per_month,
        SUM(CASE WHEN metric_name_id=6 THEN metric_value ELSE 0 END) AS message_per_month,
        SUM(CASE WHEN metric_name_id=7 THEN metric_value ELSE 0 END) AS reply_per_month,
        SUM(CASE WHEN metric_name_id=21 THEN metric_value ELSE 0 END) AS adview_per_post,
        SUM(CASE WHEN metric_name_id=22 THEN metric_value ELSE 0 END) AS reply_per_message,
        SUM(CASE WHEN metric_name_id=23 THEN metric_value ELSE 0 END) AS like_per_post,
        SUM(CASE WHEN metric_name_id=24 THEN metric_value ELSE 0 END) AS post_per_message,
        SUM(CASE WHEN metric_name_id=25 THEN metric_value ELSE 0 END) AS unfriend_per_newfriend,
        SUM(CASE WHEN metric_name_id=27 THEN metric_value ELSE 0 END) AS dislike_pcnt,
        SUM(CASE WHEN metric_name_id=30 THEN metric_value ELSE 0 END) AS newfriend_pcnt_chng,
        SUM(CASE WHEN metric_name_id=31 THEN metric_value ELSE 0 END) AS days_since_newfriend
      FROM 
        metric AS m 
INNER JOIN 
        metric_date AS d 
        ON 
        m.metric_time = d.last_metric_time
INNER JOIN 
        account_tenures AS t 
        ON t.account_id = m.account_id
INNER JOIN 
        subscriptiON AS s 
        ON m.account_id = s.account_id
INNER JOIN 
        account AS a 
        ON m.account_id = a.id
     WHERE s.start_date <= d.last_metric_time
       AND (s.end_date >= d.last_metric_time or s.end_date is null)
  GROUP BY 
        s.account_id, 
        d.last_metric_time, 
        a.channel, 
        a.country, 
        a.date_of_birth
  ORDER BY 
        s.account_id
