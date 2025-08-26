#!/usr/bin/env python3

import logging
import os

import boto3
from botocore.exceptions import ClientError

ENVIRONMENT = os.getenv("ENVIRONMENT")
MY_SECRET_NAME = os.getenv("SOME_SECRET_NAME")
secrets_client = boto3.client("secretsmanager")

logger = logging.getLogger()
logger.setLevel("INFO")

def _get_from_secret(secret_name):
    try:
        secret_value = secrets_client.get_secret_value(SecretId=secret_name)
        return secret_value['SecretString']
    except ClientError as e:
        raise RuntimeError(f"Failed to retrieve secret {secret_name} : {e}")

def lambda_handler(event, context):
    logger.info(f"Lambda function ARN: {context.invoked_function_arn}")
    logger.info(f"CloudWatch log stream name: {context.log_stream_name}")
    logger.info(f"CloudWatch log group name: {context.log_group_name}")
    logger.info(f"Lambda Request ID: {context.aws_request_id}")
    logger.info(f"Lambda function memory limits in MB: {context.memory_limit_in_mb}")
    logger.info(f"Lambda time remaining in MS: {context.get_remaining_time_in_millis()}")
    # DO SOMETHING
    secret_value = _get_from_secret(MY_SECRET_NAME)
    logger.info(f"Secret {MY_SECRET_NAME} retrieved from secrets manager...")
    logger.info(f"Lambda time remaining in MS: {context.get_remaining_time_in_millis()}")