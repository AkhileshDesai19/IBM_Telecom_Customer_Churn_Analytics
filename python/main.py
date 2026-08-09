"""
=====================================================
Project : Telecom Customer Churn Analytics
Author  : Akhilesh Desai

Description:
Main ETL pipeline controller.

Current Pipeline:
AWS S3 → Extract → Validate

Later stages:
Transform → Load → PostgreSQL
=====================================================
"""

from extract import extract_from_s3
from validate import validate_data
from transform import transform_data
from load import load_to_postgresql



def main():

    print("\n")
    print("=" * 60)
    print("TELECOM CUSTOMER CHURN ETL PIPELINE")
    print("=" * 60)

    # =================================================
    # STEP 1 — Extract
    # =================================================

    print("\nSTEP 1: DATA EXTRACTION")

    df = extract_from_s3()

    # =================================================
    # STEP 2 — Validate
    # =================================================

    print("\nSTEP 2: DATA VALIDATION")

    validation_passed = validate_data(df)

    # =================================================
    # Pipeline Decision
    # =================================================

    if not validation_passed:

        print("\n❌ ETL PIPELINE STOPPED")
        print("Data validation failed.")
        print("Please investigate the validation errors.")

        return

    print("\n✅ EXTRACTION + VALIDATION COMPLETED")

    print("\nNext ETL stage:")
    print("Transform → Silver Layer → PostgreSQL")

    print("\nSTEP 3: SILVER TRANSFORMATION")

    silver_df = transform_data(df)

    print("\nTransformed dataset preview:")
    print(silver_df.head())

    print("\nTransformed dataset shape:")
    print(silver_df.shape)
    
    print("\nSTEP 4: POSTGRESQL LOAD")

    load_to_postgresql(
        bronze_df=df,
        silver_df=silver_df
    )
    
if __name__ == "__main__":
    main()
    
    