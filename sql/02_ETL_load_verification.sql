-- =====================================================
-- PostgreSQL ETL Load Verification
-- =====================================================

-- 1. Verify Bronze record count
SELECT
    COUNT(*) AS bronze_records
FROM bronze.customers_raw;


-- 2. Verify Silver record count
SELECT
    COUNT(*) AS silver_records
FROM silver.fact_customer_churn;


-- 3. Compare Bronze and Silver counts
SELECT
    (SELECT COUNT(*) FROM bronze.customers_raw)
        AS bronze_records,

    (SELECT COUNT(*) FROM silver.fact_customer_churn)
        AS silver_records;


-- 4. Preview Bronze data
SELECT *
FROM bronze.customers_raw
LIMIT 5;


-- 5. Preview Silver data
SELECT *
FROM silver.fact_customer_churn
LIMIT 5;


-- 6. Verify Silver columns
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'fact_customer_churn'
ORDER BY ordinal_position;


-- 7. Verify customer uniqueness
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM silver.fact_customer_churn;


-- 8. Verify churn distribution
SELECT
    churn_flag,
    COUNT(*) AS customer_count
FROM silver.fact_customer_churn
GROUP BY churn_flag
ORDER BY churn_flag;


-- 9. Verify risk segment distribution
SELECT
    churn_risk_segment,
    COUNT(*) AS customer_count
FROM silver.fact_customer_churn
GROUP BY churn_risk_segment
ORDER BY customer_count DESC;