#!/usr/bin/env bash
set -euo pipefail

ROLE_ARN="arn:aws:iam::197423061312:role/SMExecutiojnRoleFoodForecast"
MODEL_DATA_S3="s3://food-forecast-artifacts-jedda-123/models/lstm/model.tar.gz"

REGION="${REGION:-us-east-1}"
PROFILE="${PROFILE:-capstone}"
ENDPOINT_NAME="${ENDPOINT_NAME:-food-forecast-lstm-v2}"
INSTANCE_TYPE="${INSTANCE_TYPE:-ml.c5.large}"
IMAGE_URI="763104351884.dkr.ecr.${REGION}.amazonaws.com/tensorflow-inference:2.13-cpu"

echo "Region: $REGION"
echo "Profile: $PROFILE"
echo "Endpoint: $ENDPOINT_NAME"

aws sagemaker create-model \
  --region "$REGION" --profile "$PROFILE" \
  --model-name "${ENDPOINT_NAME}-model" \
  --primary-container Image="$IMAGE_URI",ModelDataUrl="$MODEL_DATA_S3" \
  --execution-role-arn "$ROLE_ARN" || true

aws sagemaker create-endpoint-config \
  --region "$REGION" --profile "$PROFILE" \
  --endpoint-config-name "${ENDPOINT_NAME}-config" \
  --production-variants VariantName=AllTraffic,ModelName="${ENDPOINT_NAME}-model",InitialInstanceCount=1,InstanceType="$INSTANCE_TYPE",InitialVariantWeight=1.0 || true

aws sagemaker create-endpoint \
  --region "$REGION" --profile "$PROFILE" \
  --endpoint-name "$ENDPOINT_NAME" \
  --endpoint-config-name "${ENDPOINT_NAME}-config" || true

aws sagemaker wait endpoint-in-service \
  --region "$REGION" --profile "$PROFILE" \
  --endpoint-name "$ENDPOINT_NAME"

aws sagemaker describe-endpoint \
  --region "$REGION" --profile "$PROFILE" \
  --endpoint-name "$ENDPOINT_NAME" \
  --query "EndpointStatus"

echo " Endpoint $ENDPOINT_NAME is now InService"

