-- 4.3.3 Finding active periods that are ongoing

WITH RECURSIVE active_period_params AS (
    SELECT
        interval '%gap_interval' AS allowed_gap,
        '%to_yyyy-mm-dd'::date AS calc_date
),
active AS (
  -- find all accounts that are currently active
    SELECT
  DISTINCT
        account_id,
        min(start_date) AS start_date
      FROM socialnet7.subscription
INNER JOIN active_period_params AS params
        ON start_date <= params.calc_date
       AND (end_date > params.calc_date OR end_date IS null)
  GROUP BY account_id

     UNION
  -- find earlier subscriptions that overlapped with or are continuous with
  -- but older than the subscriptions currently found
    SELECT
        subs.account_id,
        subs.start_date
      FROM socialnet7.subscription AS subs
CROSS JOIN active_period_params AS params
INNER JOIN active -- self, i.e. recursive join
        ON subs.account_id = active.account_id
       AND subs.start_date < active.start_date
       AND subs.end_date >= (active.start_date - params.allowed_gap)::date
)

INSERT INTO active_period (account_id, start_date, churn_date)
     SELECT
        account_id,
        min(start_date) AS start_date,
        NULL::date as churn_date
       FROM active
   GROUP BY account_id, churn_date
