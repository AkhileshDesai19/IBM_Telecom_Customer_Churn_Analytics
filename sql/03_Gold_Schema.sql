-- Creating Gold Schema

/*
=====================================================
Project : IBM Telecom Churn Analytics
Author  : Akhilesh Desai
Database: PostgreSQL

Description:
Creates Gold Layer views for business reporting,
KPI analysis, customer churn analysis, and
Power BI dashboards.

Gold Layer:
- Executive KPIs
- Churn metrics
- Customer value metrics
- Risk metrics
=====================================================
*/

-- =====================================================
-- Create Gold Schema
-- =====================================================

CREATE SCHEMA IF NOT EXISTS gold;

-- =====================================================
-- Executive KPI Summary
-- Purpose:
-- Provides high-level business KPIs for management
-- reporting and the Power BI executive dashboard.
-- =====================================================

CREATE OR REPLACE VIEW gold.kpi_summary AS

SELECT

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 0
    ) AS retained_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (
                WHERE churn_flag = 1
            ) / COUNT(*)
        )::numeric,
        2
    ) AS churn_rate,

    ROUND(
        SUM(monthly_charges)::numeric,
        2
    ) AS total_monthly_revenue,

    ROUND(
        AVG(monthly_charges)::numeric,
        2
    ) AS average_monthly_charge,

    ROUND(
        AVG(tenure)::numeric,
        2
    ) AS average_tenure,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_customer_lifetime_value,

    COUNT(*) FILTER (
        WHERE high_value_customer_flag = 1
    ) AS high_value_customers,

    COUNT(*) FILTER (
        WHERE churn_risk_segment = 'High'
    ) AS high_risk_customers

FROM silver.fact_customer_churn;

-- Preview KPI Summary

SELECT *
FROM gold.kpi_summary;


-- =====================================================
-- Churn Analysis by Contract Type
-- Purpose:
-- Identifies contract types associated with higher
-- customer churn and compares customer behavior.
-- =====================================================

CREATE OR REPLACE VIEW gold.churn_by_contract AS

SELECT

    contract,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 0
    ) AS retained_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (
                WHERE churn_flag = 1
            ) / COUNT(*)
        )::numeric,
        2
    ) AS churn_rate,

    ROUND(
        AVG(monthly_charges)::numeric,
        2
    ) AS average_monthly_charge,

    ROUND(
        AVG(tenure)::numeric,
        2
    ) AS average_tenure,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value

FROM silver.fact_customer_churn

GROUP BY contract

ORDER BY churn_rate DESC;

-- Preview Churn by Contract

SELECT *
FROM gold.churn_by_contract;


-- =====================================================
-- Churn Analysis by Tenure Segment
-- Purpose:
-- Identifies customer lifecycle stages associated
-- with higher churn and customer value differences.
-- =====================================================

CREATE OR REPLACE VIEW gold.churn_by_tenure AS

SELECT

    tenure_segment,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 0
    ) AS retained_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (
                WHERE churn_flag = 1
            ) / COUNT(*)
        )::numeric,
        2
    ) AS churn_rate,

    ROUND(
        AVG(monthly_charges)::numeric,
        2
    ) AS average_monthly_charge,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value

FROM silver.fact_customer_churn

GROUP BY tenure_segment

ORDER BY churn_rate DESC;

SELECT *
FROM gold.churn_by_tenure;


-- =====================================================
-- Churn Analysis by Payment Method
-- Purpose:
-- Identifies payment methods associated with
-- different customer churn rates.
-- =====================================================

CREATE OR REPLACE VIEW gold.churn_by_payment_method AS

SELECT

    payment_method,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 0
    ) AS retained_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (
                WHERE churn_flag = 1
            ) / COUNT(*)
        )::numeric,
        2
    ) AS churn_rate,

    ROUND(
        AVG(monthly_charges)::numeric,
        2
    ) AS average_monthly_charge,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value

FROM silver.fact_customer_churn

GROUP BY payment_method

ORDER BY churn_rate DESC;

SELECT *
FROM gold.churn_by_payment_method;

-- =====================================================
-- Churn Analysis by Internet Service
-- Purpose:
-- Identifies differences in churn across
-- internet service categories.
-- =====================================================

CREATE OR REPLACE VIEW gold.churn_by_internet_service AS

SELECT

    internet_service,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 0
    ) AS retained_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (
                WHERE churn_flag = 1
            ) / COUNT(*)
        )::numeric,
        2
    ) AS churn_rate,

    ROUND(
        AVG(monthly_charges)::numeric,
        2
    ) AS average_monthly_charge,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value

FROM silver.fact_customer_churn

GROUP BY internet_service

ORDER BY churn_rate DESC;

SELECT *
FROM gold.churn_by_internet_service;


-- =====================================================
-- Churn Analysis by Risk Segment
-- Purpose:
-- Measures customer churn across risk segments
-- generated during the Silver transformation.
-- =====================================================

CREATE OR REPLACE VIEW gold.churn_by_risk_segment AS

SELECT

    risk_segment,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 0
    ) AS retained_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (
                WHERE churn_flag = 1
            ) / COUNT(*)
        )::numeric,
        2
    ) AS churn_rate,

    ROUND(
        AVG(risk_score)::numeric,
        2
    ) AS average_risk_score,

    ROUND(
        AVG(monthly_charges)::numeric,
        2
    ) AS average_monthly_charge,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value

FROM silver.fact_customer_churn

GROUP BY risk_segment

ORDER BY churn_rate DESC;

SELECT *
FROM gold.churn_by_risk_segment;

-- =====================================================
-- High-Value High-Risk Customers
-- Purpose:
-- Identifies valuable customers who are classified
-- as high risk and prioritizes them for retention.
-- =====================================================
DROP VIEW IF EXISTS gold.high_value_high_risk_customers;

CREATE VIEW gold.high_value_high_risk_customers AS

SELECT

    customer_id,
    gender,
    tenure,
    tenure_segment,
    contract,
    internet_service,
    payment_method,

    ROUND(monthly_charges::numeric, 2) AS monthly_charges,

    ROUND(estimated_customer_value::numeric, 2)
        AS estimated_customer_value,

    ROUND(calculated_lifetime_value::numeric, 2)
        AS calculated_lifetime_value,

    risk_score,
    risk_segment,
    risk_category,
    churn_risk_segment,
    high_value_customer_flag,
    churn,
    churn_flag

FROM silver.fact_customer_churn

WHERE high_value_customer_flag = 1
  AND risk_segment = 'High Risk'

ORDER BY calculated_lifetime_value DESC;

SELECT *
FROM gold.high_value_high_risk_customers
LIMIT 20;

-- =====================================================
-- Service Adoption & Churn Analysis
-- Purpose:
-- Analyzes the relationship between the number of
-- services used by customers and churn behavior.
-- =====================================================

CREATE OR REPLACE VIEW gold.service_adoption_churn AS

SELECT

    service_count,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 0
    ) AS active_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (
                WHERE churn_flag = 1
            ) /
            NULLIF(COUNT(*), 0)
        )::numeric,
        2
    ) AS churn_rate,

    ROUND(
        AVG(monthly_charges)::numeric,
        2
    ) AS average_monthly_charges,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value

FROM silver.fact_customer_churn

GROUP BY service_count

ORDER BY service_count;

SELECT *
FROM gold.service_adoption_churn;

-- =====================================================
-- Customer Lifetime Value Analysis
-- Purpose:
-- Analyzes customer value distribution and churn
-- behavior across customer lifetime value segments.
-- =====================================================

CREATE OR REPLACE VIEW gold.lifetime_value_analysis AS

SELECT

    CASE
        WHEN calculated_lifetime_value < 1000
            THEN 'Low Value'
        WHEN calculated_lifetime_value < 3000
            THEN 'Medium Value'
        WHEN calculated_lifetime_value < 6000
            THEN 'High Value'
        ELSE 'Very High Value'
    END AS value_segment,

    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn_flag = 0
    ) AS active_customers,

    ROUND(
        (
            100.0 *
            COUNT(*) FILTER (
                WHERE churn_flag = 1
            ) /
            NULLIF(COUNT(*), 0)
        )::numeric,
        2
    ) AS churn_rate,

    ROUND(
        AVG(calculated_lifetime_value)::numeric,
        2
    ) AS average_lifetime_value,

    ROUND(
        SUM(calculated_lifetime_value)::numeric,
        2
    ) AS total_lifetime_value

FROM silver.fact_customer_churn

GROUP BY
    CASE
        WHEN calculated_lifetime_value < 1000
            THEN 'Low Value'
        WHEN calculated_lifetime_value < 3000
            THEN 'Medium Value'
        WHEN calculated_lifetime_value < 6000
            THEN 'High Value'
        ELSE 'Very High Value'
    END

ORDER BY average_lifetime_value;

SELECT *
FROM gold.lifetime_value_analysis;