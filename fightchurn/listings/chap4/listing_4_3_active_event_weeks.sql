-- listing_4_3_active_event_weeks

WITH periods AS (
    SELECT
        i::timestamp AS period_start,
        i::timestamp + '7 day'::interval AS period_end
      FROM
        generate_series('%from_yyyy-mm-dd', '%to_yyyy-mm-dd', '7 day'::interval) AS i
)

INSERT INTO active_week (account_id, start_date, end_date)
    SELECT
        account_id,
        period_start::date,
        period_end::date
      FROM
        event
INNER JOIN periods
        ON event_time >= period_start
       AND event_time < period_end
  GROUP BY account_id, period_start, period_end

