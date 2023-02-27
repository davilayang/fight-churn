-- 4.3.4 Finding active periods ending in churn
-- listing_4_2_churned_periods.sql

WITH RECURSIVE active_period_params AS (
  SELECT INTERVAL '%gap_interval' AS allowed_gap,
         '%to_yyyy-mm-dd'::date AS observe_end,
         '%from_yyyy-mm-dd'::date AS observe_start
),
end_dates AS (
    SELECT
  DISTINCT
        account_id,
        start_date,
        end_date,
        (end_date + allowed_gap)::date AS extension_max -- subscription extension max date
      FROM
        subscription
INNER JOIN active_period_params
        ON end_date BETWEEN observe_start AND observe_end
),
resignups AS (
    -- each account's latest end date, considering the gap between subscriptions
    SELECT
  DISTINCT
        e.account_id,
        e.end_date
      FROM end_dates AS e
INNER JOIN subscription AS s
        ON e.account_id = s.account_id
       AND s.start_date <= e.extension_max -- if new subscription starts within allowd extension dates
       AND (s.end_date > e.end_date OR s.end_date IS null) --if new subscription ends later or haven't ended than existed sessions
),
churns AS (
  -- churn if no end date from resignup table, use the last end date in end dates
         SELECT
             e.account_id,
             e.start_date,
             e.end_date AS churn_date
           FROM
             end_dates AS e
LEFT OUTER JOIN resignups AS r
             ON e.account_id = r.account_id 
                AND e.end_date = r.end_date
          WHERE r.end_date IS null

          UNION

  -- churn if ...
         SELECT
              s.account_id,
              s.start_date,
              e.churn_date
           FROM subscription AS s
     CROSS JOIN active_period_params
     INNER JOIN churns e ON s.account_id=e.account_id
            AND s.start_date < e.start_date
            AND s.end_date >= (e.start_date- allowed_gap)::date
)
INSERT INTO active_period (account_id, start_date, churn_date)
    SELECT
        account_id,
        MIN(start_date) AS start_date,
        churn_date
      FROM churns
  GROUP BY account_id, churn_date
