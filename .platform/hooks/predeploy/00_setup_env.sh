#!/bin/bash
set -e

yum install -y jq

SECRET_NAME="$DB_SECRET_NAME"

if [ -z "$SECRET_NAME" ]; then
    echo "Error: DB_SECRET_NAME is not set"
    exit 1
fi

echo "Fetching secret from AWS Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
--region ap-northeast-2 \
--secret-id "$SECRET_NAME" \
--query 'SecretString' \
--output text)

USERNAME=$(echo "$SECRET_JSON" | jq -r '.username')
PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port')

cat <<EOF > .env
DATABASE_URL="postgres://$USERNAME:$PASSWORD@$DB_HOST:$DB_PORT/public?schema=public"
EOF