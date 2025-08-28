set -euo pipefail
REGION="${REGION:-us-east-1}"
PROFILE="${PROFILE:-capstone}"
ENDPOINT_NAME="${ENDPOINT_NAME:-food-forecast-lstm-v2}"

aws sagemaker delete-endpoint \
  --region "$REGION" --profile "$PROFILE" \
  --endpoint-name "$ENDPOINT_NAME" || true

aws sagemaker delete-endpoint-config \
  --region "$REGION" --profile "$PROFILE" \
  --endpoint-config-name "${ENDPOINT_NAME}-config" || true

aws sagemaker delete-model \
  --region "$REGION" --profile "$PROFILE" \
  --model-name "${ENDPOINT_NAME}-model" || true

echo "Deleted model/config/endpoint for $ENDPOINT_NAME"
