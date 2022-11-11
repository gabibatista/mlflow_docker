FROM python:3.7-slim-buster
RUN pip install mlflow==1.24.0 boto3 google-cloud-storage
