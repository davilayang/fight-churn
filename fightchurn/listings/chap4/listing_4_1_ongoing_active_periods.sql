WITH RECURSIVE active_period_params AS
(
    SELECT
        interval '%gap_interval' AS allowed_gap,
        '%to_yyyy-mm-dd'::date AS calc_date
),
active AS
(
    SELECT
  DISTINCT
        account_id,
        min(start_date) AS start_date
      FROM subscription
INNER JOIN active_period_params
        ON start_date <= calc_date
       AND (end_date > calc_date OR end_date IS null)
  GROUP BY account_id

    UNION

    SELECT
        s.account_id,
        s.start_date
      FROM subscription s
CROSS JOIN active_period_params
INNER JOIN active e
        ON s.account_id=e.account_id
       AND s.start_date < e.start_date
       AND s.end_date >= (e.start_date-allowed_gap)::date

)

INSERT INTO active_period (account_id, start_date, churn_date)
     SELECT
        account_id,
        min(start_date) AS start_date,
        NULL::date as churn_date
       FROM active
   GROUP BY account_id, churn_date
