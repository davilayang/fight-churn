-- listing_3_4_metric_name_insert.sql

INSERT INTO metric_name VALUES (%new_metric_id,'%new_metric_name')
ON CONFLICT DO NOTHING;
