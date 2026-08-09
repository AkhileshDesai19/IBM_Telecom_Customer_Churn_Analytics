-- =====================================================
-- BUSINESS QUESTION 1
-- How much customer lifetime value has been lost
-- due to customer churn?
-- =====================================================

SELECT

    COUNT(*) AS churned_customers,

    ROUND(
        SUM(calculated_lifetime_value)::numeric,
        2
    ) AS churned_customer_lifetime_value,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value_lost_per_customer,

    ROUND(
        (
            100.0 *
            SUM(calculated_lifetime_value) /
            NULLIF(
                (
                    SELECT SUM(calculated_lifetime_value)
                    FROM silver.fact_customer_churn
                ),
                0
            )
        )::numeric,
        2
    ) AS percentage_of_total_lifetime_value_lost

FROM silver.fact_customer_churn

WHERE churn_flag = 1;

-- =====================================================
-- BUSINESS QUESTION 2
-- Which risk segment has the greatest lifetime value
-- at risk due to customer churn?
-- =====================================================

SELECT

    risk_segment,

    COUNT(*) AS churned_customers,

    ROUND(
        SUM(calculated_lifetime_value)::numeric,
        2
    ) AS lifetime_value_at_risk,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value_per_churned_customer,

    ROUND(
        (
            100.0 *
            SUM(calculated_lifetime_value) /
            NULLIF(
                (
                    SELECT SUM(calculated_lifetime_value)
                    FROM silver.fact_customer_churn
                    WHERE churn_flag = 1
                ),
                0
            )
        )::numeric,
        2
    ) AS percentage_of_total_value_at_risk

FROM silver.fact_customer_churn

WHERE churn_flag = 1

GROUP BY risk_segment

ORDER BY lifetime_value_at_risk DESC;

-- =====================================================
-- BUSINESS QUESTION 3
-- Which contract type has the greatest lifetime value
-- at risk due to customer churn?
-- =====================================================

SELECT

    contract,

    COUNT(*) AS churned_customers,

    ROUND(
        SUM(calculated_lifetime_value)::numeric,
        2
    ) AS lifetime_value_at_risk,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value_per_churned_customer,

    ROUND(
        (
            100.0 *
            SUM(calculated_lifetime_value) /
            NULLIF(
                (
                    SELECT SUM(calculated_lifetime_value)
                    FROM silver.fact_customer_churn
                    WHERE churn_flag = 1
                ),
                0
            )
        )::numeric,
        2
    ) AS percentage_of_total_value_at_risk

FROM silver.fact_customer_churn

WHERE churn_flag = 1

GROUP BY contract

ORDER BY lifetime_value_at_risk DESC;

-- =====================================================
-- BUSINESS QUESTION 4
-- Which contract + risk segment combination has the
-- greatest lifetime value at risk?
-- =====================================================

SELECT

    contract,

    risk_segment,

    COUNT(*) AS churned_customers,

    ROUND(
        SUM(calculated_lifetime_value)::numeric,
        2
    ) AS lifetime_value_at_risk,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value_per_churned_customer,

    ROUND(
        (
            100.0 *
            SUM(calculated_lifetime_value) /
            NULLIF(
                (
                    SELECT SUM(calculated_lifetime_value)
                    FROM silver.fact_customer_churn
                    WHERE churn_flag = 1
                ),
                0
            )
        )::numeric,
        2
    ) AS percentage_of_total_value_at_risk

FROM silver.fact_customer_churn

WHERE churn_flag = 1

GROUP BY
    contract,
    risk_segment

ORDER BY lifetime_value_at_risk DESC;

-- =====================================================
-- BUSINESS QUESTION 5
-- Priority Customer Retention List
-- Identifies high-value customers requiring targeted
-- retention intervention.
-- =====================================================

CREATE OR REPLACE VIEW gold.priority_retention_customers AS

SELECT

    customer_id,
    gender,
    tenure,
    contract,
    internet_service,
    payment_method,

    ROUND(monthly_charges::numeric, 2)
        AS monthly_charges,

    ROUND(calculated_lifetime_value::numeric, 2)
        AS lifetime_value,

    risk_score,
    risk_segment,
    risk_category,
    churn_risk_segment,

    high_value_customer_flag,

    churn,
    churn_flag

FROM silver.fact_customer_churn

WHERE contract = 'Month-to-month'

  AND risk_segment IN ('High Risk', 'Medium Risk')

  AND high_value_customer_flag = 1

ORDER BY
    risk_score DESC,
    calculated_lifetime_value DESC;

SELECT *
FROM gold.priority_retention_customers
LIMIT 20;

SELECT
    churn_flag,
    COUNT(*) AS customer_count,
    ROUND(SUM(lifetime_value)::numeric, 2) AS total_lifetime_value
FROM gold.priority_retention_customers
GROUP BY churn_flag
ORDER BY churn_flag;

-- =====================================================
-- BUSINESS QUESTION 6
-- Which tenure segment has the greatest lifetime value
-- at risk due to customer churn?
-- =====================================================

SELECT

    tenure_segment,

    COUNT(*) AS churned_customers,

    ROUND(
        SUM(calculated_lifetime_value)::numeric,
        2
    ) AS lifetime_value_at_risk,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value_per_churned_customer,

    ROUND(
        (
            100.0 *
            SUM(calculated_lifetime_value) /
            NULLIF(
                (
                    SELECT SUM(calculated_lifetime_value)
                    FROM silver.fact_customer_churn
                    WHERE churn_flag = 1
                ),
                0
            )
        )::numeric,
        2
    ) AS percentage_of_total_value_at_risk

FROM silver.fact_customer_churn

WHERE churn_flag = 1

GROUP BY tenure_segment

ORDER BY lifetime_value_at_risk DESC;


-- =====================================================
-- FINAL GOLD LAYER VALIDATION
-- Reconcile Silver customer count with Gold views.
-- =====================================================

SELECT
    'Silver Customer Count' AS metric,
    COUNT(*) AS value
FROM silver.fact_customer_churn

UNION ALL

SELECT
    'Total Churned Customers',
    COUNT(*)
FROM silver.fact_customer_churn
WHERE churn_flag = 1

UNION ALL

SELECT
    'Total Active Customers',
    COUNT(*)
FROM silver.fact_customer_churn
WHERE churn_flag = 0

UNION ALL

SELECT
    'High Risk Customers',
    COUNT(*)
FROM silver.fact_customer_churn
WHERE risk_segment = 'High Risk'

UNION ALL

SELECT
    'Medium Risk Customers',
    COUNT(*)
FROM silver.fact_customer_churn
WHERE risk_segment = 'Medium Risk'

UNION ALL

SELECT
    'Low Risk Customers',
    COUNT(*)
FROM silver.fact_customer_churn
WHERE risk_segment = 'Low Risk'

UNION ALL

SELECT
    'High Value Customers',
    COUNT(*)
FROM silver.fact_customer_churn
WHERE high_value_customer_flag = 1;

--------------------------------------------------------------------------

CREATE OR REPLACE VIEW gold.executive_business_summary AS

SELECT
    'Total Customers' AS metric,
    COUNT(*)::numeric AS value
FROM silver.fact_customer_churn

UNION ALL

SELECT
    'Active Customers',
    COUNT(*)::numeric
FROM silver.fact_customer_churn
WHERE churn_flag = 0

UNION ALL

SELECT
    'Churned Customers',
    COUNT(*)::numeric
FROM silver.fact_customer_churn
WHERE churn_flag = 1

UNION ALL

SELECT
    'Churn Rate',
    ROUND(
        (
            100.0 * SUM(churn_flag) / NULLIF(COUNT(*), 0)
        )::numeric,
        2
    )
FROM silver.fact_customer_churn

UNION ALL

SELECT
    'Total Lifetime Value',
    ROUND(
        SUM(calculated_lifetime_value)::numeric,
        2
    )
FROM silver.fact_customer_churn

UNION ALL

SELECT
    'Churned Lifetime Value',
    ROUND(
        SUM(calculated_lifetime_value)
        FILTER (WHERE churn_flag = 1)::numeric,
        2
    )
FROM silver.fact_customer_churn

UNION ALL

SELECT
    'High Risk Customers',
    COUNT(*)::numeric
FROM silver.fact_customer_churn
WHERE risk_segment = 'High Risk'

UNION ALL

SELECT
    'High Value Customers',
    COUNT(*)::numeric
FROM silver.fact_customer_churn
WHERE high_value_customer_flag = 1;


SELECT *
FROM gold.executive_business_summary;