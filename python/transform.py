"""
=====================================================
Project : Telecom Customer Churn Analytics
Author  : Akhilesh Desai

Description:
Transforms validated telecom customer data into
an analytics-ready Silver Layer dataset.

Responsibilities:
- Standardize column names
- Enforce data types
- Create analytical fields
- Apply business transformations
- Prepare data for PostgreSQL
=====================================================
"""

import pandas as pd


def transform_data(df):

    print("\n")
    print("=" * 60)
    print("STARTING SILVER LAYER TRANSFORMATION")
    print("=" * 60)

    df = df.copy()

    # =================================================
    # 1. Standardize Column Names
    # =================================================

    print("\n[1] Standardizing column names...")

    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
    )

    print("PASS - Column names standardized.")

    # =================================================
    # 2. Enforce Data Types
    # =================================================

    print("\n[2] Enforcing data types...")

    integer_columns = [
        "senior_citizen",
        "tenure",
        "churn_flag",
        "service_count",
        "new_customer_flag",
        "high_monthly_charge_flag",
        "risk_score"
    ]

    for column in integer_columns:
        if column in df.columns:
            df[column] = pd.to_numeric(
                df[column],
                errors="coerce"
            ).astype("Int64")

    numeric_columns = [
        "monthly_charges",
        "total_charges",
        "estimated_customer_value"
    ]

    for column in numeric_columns:
        if column in df.columns:
            df[column] = pd.to_numeric(
                df[column],
                errors="coerce"
            )

    print("PASS - Data types standardized.")

    # =================================================
    # 3. Standardize Boolean Fields
    # =================================================

    print("\n[3] Standardizing categorical flags...")

    boolean_mapping = {
        "Yes": 1,
        "No": 0,
        "yes": 1,
        "no": 0
    }

    boolean_columns = [
        "partner",
        "dependents",
        "phone_service",
        "paperless_billing"
    ]

    for column in boolean_columns:

        if column in df.columns:

            df[column] = (
                df[column]
                .map(boolean_mapping)
                .fillna(df[column])
            )

    print("PASS - Boolean fields standardized.")

    # =================================================
    # 4. Create Customer Lifetime Value
    # =================================================

    print("\n[4] Creating customer lifetime value...")

    if {
        "monthly_charges",
        "tenure"
    }.issubset(df.columns):

        df["calculated_lifetime_value"] = (
            df["monthly_charges"] *
            df["tenure"]
        )

    print("PASS - Lifetime value calculated.")

    # =================================================
    # 5. Create Customer Risk Category
    # =================================================

    print("\n[5] Creating customer risk category...")

    if "risk_score" in df.columns:

        df["risk_category"] = pd.cut(
            df["risk_score"],
            bins=[-1, 0, 1, 2, 3],
            labels=[
                "Low Risk",
                "Medium Risk",
                "High Risk",
                "Critical Risk"
            ]
        )

    print("PASS - Risk category created.")

    # =================================================
    # 6. Create High Value Customer Flag
    # =================================================

    print("\n[6] Creating high-value customer flag...")

    if "estimated_customer_value" in df.columns:

        value_threshold = df[
            "estimated_customer_value"
        ].quantile(0.75)

        df["high_value_customer_flag"] = (
            df["estimated_customer_value"]
            >= value_threshold
        ).astype(int)

    print("PASS - High-value customer flag created.")

    # =================================================
    # 7. Create Churn Risk Segment
    # =================================================

    print("\n[7] Creating churn risk segment...")

    if {
        "churn_flag",
        "risk_score"
    }.issubset(df.columns):

        df["churn_risk_segment"] = "Low"

        df.loc[
            (df["churn_flag"] == 1) &
            (df["risk_score"] >= 2),
            "churn_risk_segment"
        ] = "Critical"

        df.loc[
            (df["churn_flag"] == 1) &
            (df["risk_score"] == 1),
            "churn_risk_segment"
        ] = "High"

        df.loc[
            (df["churn_flag"] == 0) &
            (df["risk_score"] >= 2),
            "churn_risk_segment"
        ] = "Medium"

    print("PASS - Churn risk segment created.")

    # =================================================
    # 8. Remove Temporary / Unnecessary Fields
    # =================================================

    print("\n[8] Preparing final Silver dataset...")

    # Keep all original analytical columns.
    # No columns are removed here intentionally.

    # =================================================
    # 9. Final Validation
    # =================================================

    print("\n[9] Final transformation validation...")

    print(
        f"Rows after transformation : {len(df):,}"
    )

    print(
        f"Columns after transformation : {len(df.columns)}"
    )

    if df.empty:

        raise ValueError(
            "Transformation failed: dataset is empty."
        )

    print("PASS - Silver dataset is ready.")

    print("\n")
    print("=" * 60)
    print("✅ SILVER TRANSFORMATION COMPLETED")
    print("=" * 60)

    return df


if __name__ == "__main__":

    print(
        "Transform module created successfully."
    ) 
    
    