import os

# ==============================
# AWS S3 Configuration
# ==============================

S3_BUCKET = os.getenv(
    "S3_BUCKET",
    "telco-churn-analytics"
)

S3_RAW_KEY = os.getenv(
    "S3_RAW_KEY",
    "raw/telco_customer_churn_500k.csv"
)

# ==============================
# Local ETL Configuration
# ==============================

LOCAL_RAW_PATH = "data/raw/telco_customer_churn_500k.csv"

# ==============================
# PostgreSQL Configuration
# ==============================

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "telco_churn")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")

