SELECT
    viewname
FROM pg_views
WHERE schemaname = 'gold'
  AND definition ILIKE '%/%';

  SELECT * FROM gold.kpi_summary;

SELECT * FROM gold.high_value_high_risk_summary;

SELECT pg_get_viewdef(
    'gold.high_value_high_risk_summary'::regclass,
    true
);