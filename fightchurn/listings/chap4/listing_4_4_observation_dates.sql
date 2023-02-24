-- listing_4_4_observation_dates.sql

WITH RECURSIVE observation_params AS (
  SELECT interval '%obs_interval' AS obs_interval,
         interval '%lead_time'  AS lead_time,
         '%from_yyyy-mm-dd'::date AS obs_start,
         '%to_yyyy-mm-dd'::date AS obs_end,
),
observations AS (
    SELECT
        account_id,
        start_date,
        1 AS obs_count,
        (start_date + obs_interval-lead_time)::date AS obs_date,
      CASE
        WHEN churn_date >= (start_date + obs_interval-lead_time)::date
            AND churn_date <  (start_date + 2*obs_interval-lead_time)::date
          THEN true
          ELSE false
         END AS is_churn
      FROM active_period
INNER JOIN observation_params
        ON (churn_date > (obs_start+obs_interval-lead_time)::date
           OR churn_date is null)

  UNION

    SELECT
        o.account_id,
        o.start_date,
        obs_count+1 AS obs_count,
        (o.start_date+(obs_count+1)*obs_interval-lead_time)::date AS obs_date,
      CASE
        WHEN churn_date >= (o.start_date + (obs_count+1)*obs_interval-lead_time)::date
            AND churn_date < (o.start_date + (obs_count+2)*obs_interval-lead_time)::date
          THEN true
          ELSE false
       END AS is_churn
      FROM observations o
INNER JOIN observation_params
        ON (o.start_date+(obs_count+1)*obs_interval-lead_time)::date <= obs_end
INNER JOIN active_period s
        ON s.account_id=o.account_id
          AND (o.start_date+(obs_count+1)*obs_interval-lead_time)::date >= s.start_date
          AND ((o.start_date+(obs_count+1)*obs_interval-lead_time)::date < s.churn_date
                OR churn_date IS null)
)

INSERT INTO observation (account_id, observation_date, is_churn)
    SELECT
  DISTINCT account_id, obs_date, is_churn
      FROM observations
INNER JOIN observation_params
        ON obs_date
   BETWEEN obs_start and obs_end
