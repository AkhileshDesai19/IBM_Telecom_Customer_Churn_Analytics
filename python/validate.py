"""
=====================================================
Project : Telecom Customer Churn Analytics
Author  : Akhilesh Desai

Description:
Validates the dataset extracted from AWS S3 before
loading it into the PostgreSQL Bronze Layer.

Validation includes:
- Record count
- Required columns
- Missing values
- Duplicate customer IDs
- Data ranges
- Categorical values
- Business rule validation
=====================================================
"""

import pandas as pd


# =====================================================
# Expected Schema
# =====================================================

REQUIRED_COLUMNS = [
    "customer_id",
    "gender",
    "senior_citizen",
    "partner",
    "dependents",
    "tenure",
    "phone_service",
    "multiple_lines",
    "internet_service",
    "online_security",
    "online_backup",
    "device_protection",
    "tech_support",
    "streaming_tv",
    "streaming_movies",
    "contract",
    "paperless_billing",
    "payment_method",
    "monthly_charges",
    "total_charges",
    "churn",
    "churn_flag",
    "tenure_segment",
    "monthly_charge_segment",
    "estimated_customer_value",
    "service_count",
    "new_customer_flag",
    "high_monthly_charge_flag",
    "risk_score",
    "risk_segment"
]


# =====================================================
# Main Validation Function
# =====================================================

def validate_data(df):

    print("\n")
    print("=" * 60)
    print("STARTING DATA VALIDATION")
    print("=" * 60)

    validation_passed = True

    # =================================================
    # 1. Record Count
    # =================================================

    print("\n[1] Record Count")

    print(f"Total records: {len(df):,}")

    if len(df) == 500_000:
        print("PASS - Expected 500,000 records.")
    else:
        print("WARNING - Record count differs from expected.")
        validation_passed = False

    # =================================================
    # 2. Required Columns
    # =================================================

    print("\n[2] Required Column Validation")

    missing_columns = [
        col for col in REQUIRED_COLUMNS
        if col not in df.columns
    ]

    if not missing_columns:
        print("PASS - All required columns are present.")
    else:
        print("FAIL - Missing columns:")
        print(missing_columns)
        validation_passed = False

    # =================================================
    # 3. Missing Values
    # =================================================

    print("\n[3] Missing Value Validation")

    missing_values = df.isnull().sum()

    missing_values = missing_values[
        missing_values > 0
    ]

    if missing_values.empty:
        print("PASS - No missing values detected.")
    else:
        print("WARNING - Missing values detected:")
        print(missing_values)
        validation_passed = False

    # =================================================
    # 4. Duplicate Customer IDs
    # =================================================

    print("\n[4] Duplicate Customer ID Validation")

    duplicate_ids = df["customer_id"].duplicated().sum()

    print(f"Duplicate customer IDs: {duplicate_ids}")

    if duplicate_ids == 0:
        print("PASS - Customer IDs are unique.")
    else:
        print("FAIL - Duplicate customer IDs detected.")
        validation_passed = False

    # =================================================
    # 5. Tenure Validation
    # =================================================

    print("\n[5] Tenure Validation")

    invalid_tenure = (
        (df["tenure"] < 0)
        | (df["tenure"] > 72)
    ).sum()

    print(f"Invalid tenure records: {invalid_tenure}")

    if invalid_tenure == 0:
        print("PASS - Tenure values are valid.")
    else:
        print("FAIL - Invalid tenure values detected.")
        validation_passed = False

    # =================================================
    # 6. Monthly Charges Validation
    # =================================================

    print("\n[6] Monthly Charges Validation")

    invalid_monthly = (
        df["monthly_charges"] < 0
    ).sum()

    print(
        f"Negative monthly charges: {invalid_monthly}"
    )

    if invalid_monthly == 0:
        print("PASS - Monthly charges are valid.")
    else:
        print("FAIL - Negative monthly charges detected.")
        validation_passed = False

    # =================================================
    # 7. Total Charges Validation
    # =================================================

    print("\n[7] Total Charges Validation")

    invalid_total = (
        df["total_charges"] < 0
    ).sum()

    print(
        f"Negative total charges: {invalid_total}"
    )

    if invalid_total == 0:
        print("PASS - Total charges are valid.")
    else:
        print("FAIL - Negative total charges detected.")
        validation_passed = False

    # =================================================
    # 8. Churn Validation
    # =================================================

    print("\n[8] Churn Value Validation")

    valid_churn = {"Yes", "No"}

    invalid_churn = ~df["churn"].isin(valid_churn)

    invalid_count = invalid_churn.sum()

    print(f"Invalid churn values: {invalid_count}")

    if invalid_count == 0:
        print("PASS - Churn values are valid.")
    else:
        print("FAIL - Invalid churn values detected.")
        validation_passed = False

    # =================================================
    # 9. Churn Flag Validation
    # =================================================

    print("\n[9] Churn Flag Validation")

    expected_churn_flag = (
        df["churn"]
        .map({
            "Yes": 1,
            "No": 0
        })
    )

    invalid_churn_flag = (
        df["churn_flag"] != expected_churn_flag
    ).sum()

    print(
        f"Invalid churn flag records: "
        f"{invalid_churn_flag}"
    )

    if invalid_churn_flag == 0:
        print("PASS - Churn flags are consistent.")
    else:
        print("FAIL - Churn flag inconsistency detected.")
        validation_passed = False

    # =================================================
    # 10. Risk Score Validation
    # =================================================

    print("\n[10] Risk Score Validation")

    invalid_risk_score = (
        (df["risk_score"] < 0)
        | (df["risk_score"] > 3)
    ).sum()

    print(
        f"Invalid risk scores: {invalid_risk_score}"
    )

    if invalid_risk_score == 0:
        print("PASS - Risk scores are valid.")
    else:
        print("FAIL - Invalid risk scores detected.")
        validation_passed = False

    # =================================================
    # 11. Service Count Validation
    # =================================================

    print("\n[11] Service Count Validation")

    invalid_service_count = (
        (df["service_count"] < 0)
        | (df["service_count"] > 6)
    ).sum()

    print(
        f"Invalid service counts: "
        f"{invalid_service_count}"
    )

    if invalid_service_count == 0:
        print("PASS - Service counts are valid.")
    else:
        print("FAIL - Invalid service counts detected.")
        validation_passed = False

    # =================================================
    # 12. Final Validation Result
    # =================================================

    print("\n")
    print("=" * 60)

    if validation_passed:
        print("✅ DATA VALIDATION PASSED")
        print("Dataset is ready for Bronze Layer loading.")
    else:
        print("❌ DATA VALIDATION FAILED")
        print("Dataset requires investigation before loading.")

    print("=" * 60)

    return validation_passed


# =====================================================
# Standalone Testing
# =====================================================

if __name__ == "__main__":

    import sys
    import os

    print("Validation module created successfully.")

    print(
        "\nThis module expects a Pandas DataFrame "
        "from extract.py."
    )
    
    