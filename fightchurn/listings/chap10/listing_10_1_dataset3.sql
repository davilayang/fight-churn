WITH observation_params AS ( 
    SELECT  
        interval '%metric_interval' AS metric_period, 
        '%from_yyyy-mm-dd'::timestamp AS obs_start, 
        '%to_yyyy-mm-dd'::timestamp AS obs_end
)

    SELECT 
        m.account_id, 
        o.observation_date, 
        is_churn, 
        a.channel, 
        a.country,
        DATE_PART('day',o.observation_date::timestamp - a.date_of_birth::timestamp)::float/365.0 AS customer_age,
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
        observation_params 
        ON metric_time BETWEEN obs_start AND obs_end
INNER JOIN 
        observation AS o 
        ON m.account_id = o.account_id
       AND m.metric_time > (o.observation_date - metric_period)::timestamp
       AND m.metric_time <= o.observation_date::timestamp
INNER JOIN 
        account AS a 
        ON m.account_id = a.id
  GROUP BY 
        m.account_id, 
        metric_time, 
        observation_date, 
        is_churn, 
        a.channel, 
        date_of_birth, 
        country
  ORDER BY 
        observation_date,
        m.account_id
