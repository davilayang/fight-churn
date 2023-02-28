-- listing_3_13_account_tenure_insert.sql

with RECURSIVE date_vals AS (
    SELECT
        i::timestamp AS metric_date
      FROM
        generate_series('%from_yyyy-mm-dd', '%to_yyyy-mm-dd', '7 day'::interval) AS i
),
earlier_starts AS (
    SELECT
        account_id,
        metric_date,
        MIN(start_date) AS start_date
      FROM subscription
INNER JOIN date_vals
        ON start_date <= metric_date
       AND (end_date > metric_date OR end_date IS null)
  GROUP BY account_id, metric_date

    UNION

    SELECT s.account_id, metric_date, s.start_date
      FROM subscription AS s
INNER JOIN earlier_starts AS e
        ON s.account_id=e.account_id
       AND s.start_date < e.start_date
       AND s.end_date >= (e.start_date-31)
)

INSERT INTO metric (account_id,metric_time,metric_name_id, metric_value)
    SELECT
        account_id,
        metric_date,
        %new_metric_id AS metric_name_id,
        EXTRACT(days FROM metric_date-MIN(start_date)) AS metric_value
      FROM
        earlier_starts
  GROUP BY account_id, metric_date
  ORDER BY account_id, metric_date
        ON CONFLICT DO NOTHING;
