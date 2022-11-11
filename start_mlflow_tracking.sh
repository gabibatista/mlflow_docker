#!/bin/bash
MLFLOW_IMAGE=mlflow:1.24.0
CLOUD_SQL_PROXY_IMAGE=gcr.io/cloudsql-docker/gce-proxy:1.19.1
MYSQL_INSTANCE=dxt-dna-growth-cockpit:us-central1:appstore-mlflow
PWD=$(gcloud secrets versions access latest --secret="appstore-mlflow-cloud-sql-root-pwd")

echo 'Starting Cloud SQL Proxy'
docker run -d --name mysql  --net host -p 3306:3306 $CLOUD_SQL_PROXY_IMAGE /cloud_sql_proxy -instances $MYSQL_INSTANCE=tcp:0.0.0.0:3306
echo 'Starting mlflow-tracking server'
docker run -d --name mlflow-tracking --net host -p 5000:5000 $MLFLOW_IMAGE mlflow server --backend-store-uri mysql+pymysql://root:$PWD@localhost/mlflow --default-artifact-root gs://dxt-dna-app-store-mlflow/mlflow_artifacts/ --host 0.0.0.0
echo 'Altering IPTables'
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT
