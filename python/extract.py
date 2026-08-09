"""
=====================================================
Project : Telecom Customer Churn Analytics
Author  : Akhilesh Desai

Description:
Extracts the raw synthetic telecom customer dataset
from AWS S3 for downstream ETL processing.
=====================================================
"""

import os
import boto3
import pandas as pd

from config import S3_BUCKET, S3_RAW_KEY, LOCAL_RAW_PATH


def extract_from_s3():
    """
    Download the raw dataset from AWS S3 and load it
    into a Pandas DataFrame.
    """

    print("========================================")
    print("Starting S3 Data Extraction")
    print("========================================")

    print(f"S3 Bucket : {S3_BUCKET}")
    print(f"S3 Object : {S3_RAW_KEY}")

    # Create S3 client
    s3 = boto3.client("s3")

    # Create local directory if it doesn't exist
    os.makedirs(
        os.path.dirname(LOCAL_RAW_PATH),
        exist_ok=True
    )

    # Download file from S3
    print("\nDownloading dataset from S3...")

    s3.download_file(
        S3_BUCKET,
        S3_RAW_KEY,
        LOCAL_RAW_PATH
    )

    print("Download completed successfully.")

    # Load dataset
    print("\nLoading dataset into Pandas...")

    df = pd.read_csv(LOCAL_RAW_PATH)

    print(f"Dataset shape: {df.shape}")

    print("\nExtraction completed successfully.")

    return df


if __name__ == "__main__":
    df = extract_from_s3()

    print("\nSample records:")
    print(df.head())