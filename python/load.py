"""
=====================================================
Project : Telecom Customer Churn Analytics
Author  : Akhilesh Desai

Description:
Loads raw and transformed telecom churn data into
the PostgreSQL Bronze and Silver layers.

Bronze:
Stores the original extracted dataset.

Silver:
Stores the analytics-ready transformed dataset.

Database:
telecom_churn_analytics
=====================================================
"""

import os
import pandas as pd
from sqlalchemy import create_engine, text


# =====================================================
# PostgreSQL Configuration
# =====================================================

DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "telecom_churn_analytics"
DB_USER = "postgres"


DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")


# =====================================================
# Create PostgreSQL Connection
# =====================================================

def get_engine():

    if not DB_PASSWORD:
        raise ValueError(
            "POSTGRES_PASSWORD environment variable "
            "is not set."
        )

    connection_url = (
        f"postgresql+psycopg2://"
        f"{DB_USER}:{DB_PASSWORD}@"
        f"{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )

    engine = create_engine(
        connection_url,
        pool_pre_ping=True
    )

    return engine


# =====================================================
# Create Required Schemas
# =====================================================

def create_schemas(engine):

    print("\nCreating PostgreSQL schemas...")

    with engine.begin() as connection:

        connection.execute(
            text("CREATE SCHEMA IF NOT EXISTS bronze;")
        )

        connection.execute(
            text("CREATE SCHEMA IF NOT EXISTS silver;")
        )

        connection.execute(
            text("CREATE SCHEMA IF NOT EXISTS gold;")
        )

    print("PASS - Bronze, Silver and Gold schemas ready.")


# =====================================================
# Load Bronze Layer
# =====================================================

def load_bronze(df, engine):

    print("\n")
    print("=" * 60)
    print("LOADING BRONZE LAYER")
    print("=" * 60)

    print(
        f"Records to load: {len(df):,}"
    )

    # Create/replace Bronze table
    df.to_sql(
        name="customers_raw",
        con=engine,
        schema="bronze",
        if_exists="replace",
        index=False,
        chunksize=10000,
        method="multi"
    )

    print(
        "PASS - Bronze table loaded successfully."
    )

    # Verify record count
    with engine.connect() as connection:

        result = connection.execute(
            text(
                "SELECT COUNT(*) "
                "FROM bronze.customers_raw;"
            )
        )

        count = result.scalar()

    print(
        f"Bronze records loaded: {count:,}"
    )
    
    


# =====================================================
# Load Silver Layer
# =====================================================

def load_silver(df, engine):

    print("\n")
    print("=" * 60)
    print("LOADING SILVER LAYER")
    print("=" * 60)

    print(
        f"Records to load: {len(df):,}"
    )

    # Load transformed dataframe
    df.to_sql(
        name="fact_customer_churn",
        con=engine,
        schema="silver",
        if_exists="replace",
        index=False,
        chunksize=10000,
        method="multi"
    )

    print(
        "PASS - Silver table loaded successfully."
    )

    # Verify count
    with engine.connect() as connection:

        result = connection.execute(
            text(
                "SELECT COUNT(*) "
                "FROM silver.fact_customer_churn;"
            )
        )

        count = result.scalar()

    print(
        f"Silver records loaded: {count:,}"
    )


# =====================================================
# Test PostgreSQL Connection
# =====================================================

def test_connection(engine):

    print("\nTesting PostgreSQL connection...")

    with engine.connect() as connection:

        result = connection.execute(
            text("SELECT version();")
        )

        version = result.scalar()

    print("PASS - PostgreSQL connection successful.")

    print(
        f"PostgreSQL: {version.split(',')[0]}"
    )


# =====================================================
# Main Load Function
# =====================================================

def load_to_postgresql(bronze_df, silver_df):

    print("\n")
    print("=" * 60)
    print("POSTGRESQL DATA LOAD")
    print("=" * 60)

    engine = get_engine()

    test_connection(engine)

    create_schemas(engine)

    load_bronze(
        bronze_df,
        engine
    )

    load_silver(
        silver_df,
        engine
    )

    print("\n")
    print("=" * 60)
    print("✅ POSTGRESQL LOAD COMPLETED")
    print("=" * 60)

    return engine


# =====================================================
# Standalone Test
# =====================================================

if __name__ == "__main__":

    print(
        "Load module created successfully."
    )

    print(
        "\nThis module expects Bronze and Silver "
        "DataFrames from main.py."
    )
    