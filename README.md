
# Executive Summary
This project demonstrates deploying an LSTM-based forecasting model for food vendor sales to AWS SageMaker. The workflow includes converting a legacy .h5 model to a modern TensorFlow SavedModel, packaging and storing it in S3, configuring IAM for secure access, and deploying the model to a managed TensorFlow Serving container. A live endpoint was created and tested with real-time predictions, completing the deployment phase of the capstone project.

# Quick Start 

### 0) Repo + Python venv
cd ~/capstone-forecasting-food-sales
python3.11 -m venv .venv
source .venv/bin/activate

### 1) Environment
export AWS_PROFILE=capstone
export AWS_REGION=us-east-1
export ARTIFACT_BUCKET=food-forecast-artifacts-jedda-123
export ROLE_NAME=SMExecutiojnRoleFoodForecast
export ENDPOINT_NAME=food-forecast-lstm-v2

### 2) Tooling (Apple Silicon + TF 2.13)
python -m pip install --upgrade pip setuptools wheel
python -m pip install "tensorflow-macos==2.13.1" "numpy==1.23.5" \
  "protobuf>=3.20.3,<5" "h5py<4" boto3 "sagemaker==2.*"

### 3) Convert .h5 -> .keras and export SavedModel (input: [None,30,1])
python - <<'PY'
import tensorflow as tf
from tensorflow import keras
import os
m = keras.models.load_model("lstm_model.h5", compile=False, safe_mode=False)
m.save("lstm_model.keras")
TIMESTEPS, N_FEATURES = 30, 1
export_dir = "build/export/1"; os.makedirs(export_dir, exist_ok=True)
@tf.function(input_signature=[tf.TensorSpec([None,TIMESTEPS,N_FEATURES], tf.float32, name="inputs")])
def serve_fn(x): return {"outputs": m(x)}
tf.saved_model.save(m, export_dir, signatures={"serving_default": serve_fn})
print("SavedModel ->", export_dir)
PY

### 4) Package + upload to S3
cd build/export && tar -czf ../../model.tar.gz 1 && cd ../../
aws s3 cp model.tar.gz s3://$ARTIFACT_BUCKET/models/lstm/model.tar.gz \
  --region $AWS_REGION --profile $AWS_PROFILE
export MODEL_S3_URI=s3://$ARTIFACT_BUCKET/models/lstm/model.tar.gz

### 5) Resolve role ARN
export SAGEMAKER_ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME \
  --query 'Role.Arn' --output text --profile $AWS_PROFILE)

### 6) Deploy TensorFlow Serving 2.13 (CPU)
python - <<'PY'
import os, boto3, sagemaker
from sagemaker import image_uris
from sagemaker.tensorflow.model import TensorFlowModel
region=os.environ["AWS_REGION"]; role=os.environ["SAGEMAKER_ROLE_ARN"]
model_data=os.environ["MODEL_S3_URI"]; endpoint=os.environ["ENDPOINT_NAME"]
instance_type="ml.c5.large"
sess=sagemaker.Session(boto_session=boto3.Session(region_name=region))
image=image_uris.retrieve(framework="tensorflow", region=region, version="2.13",
                          image_scope="inference", instance_type=instance_type)
m=TensorFlowModel(model_data=model_data, role=role, framework_version="2.13",
                  image_uri=image, sagemaker_session=sess)
m.deploy(initial_instance_count=1, instance_type=instance_type, endpoint_name=endpoint)
print("Deployed:", endpoint)
PY

### 7) Wait until ready (expect 'InService')
aws sagemaker describe-endpoint --endpoint-name "$ENDPOINT_NAME" \
  --query 'EndpointStatus' --output text --profile $AWS_PROFILE --region $AWS_REGION

### 8) Smoke test
python - <<'PY'
import os, json, numpy as np, boto3
rt=boto3.client("sagemaker-runtime", region_name=os.environ.get("AWS_REGION","us-east-1"))
x=np.random.rand(1,30,1).tolist()
r=rt.invoke_endpoint(EndpointName=os.environ["ENDPOINT_NAME"],
                     ContentType="application/json",
                     Body=json.dumps({"instances": x}))
print("Prediction:", r["Body"].read().decode())
PY

### 9) Cleanup (stop billing when done)
aws sagemaker delete-endpoint --endpoint-name "$ENDPOINT_NAME" \
  --profile $AWS_PROFILE --region $AWS_REGION
aws sagemaker delete-endpoint-config --endpoint-config-name "$ENDPOINT_NAME" \
  --profile $AWS_PROFILE --region $AWS_REGION
aws sagemaker delete-model --model-name "$ENDPOINT_NAME" \
  --profile $AWS_PROFILE --region $AWS_REGION


# Detailed Deployment Steps 

## Forecasting Food Sales – SageMaker Deployment
This project demonstrates deploying an LSTM model for food vendor sales forecasting to an AWS SageMaker endpoint. The workflow covers model conversion, packaging, S3 upload, IAM configuration, endpoint deployment, prediction testing, monitoring, and cleanup.
## 1. Environment Setup

cd ~/capstone-forecasting-food-sales
python3.11 -m venv .venv
source .venv/bin/activate

export AWS_PROFILE=capstone
export AWS_REGION=us-east-1
export ARTIFACT_BUCKET=food-forecast-artifacts-jedda-123
export ROLE_NAME=SMExecutiojnRoleFoodForecast


## 2. Convert and Export Model
Convert legacy .h5 to .keras, then export a TensorFlow SavedModel with the proper input signature.

python - <<'PY'
import tensorflow as tf
from tensorflow import keras
import os

m = keras.models.load_model("lstm_model.h5", compile=False, safe_mode=False)
m.save("lstm_model.keras")

TIMESTEPS, N_FEATURES = 30, 1
export_dir = "build/export/1"
os.makedirs(export_dir, exist_ok=True)

@tf.function(input_signature=[tf.TensorSpec([None, TIMESTEPS, N_FEATURES], tf.float32, name="inputs")])
def serve_fn(x):
    return {"outputs": m(x)}

tf.saved_model.save(m, export_dir, signatures={"serving_default": serve_fn})
PY

## 3. Package and Upload to S3

cd build/export
tar -czf ../../model.tar.gz 1
cd ../../

aws s3 cp model.tar.gz s3://$ARTIFACT_BUCKET/models/lstm/model.tar.gz \
  --region $AWS_REGION --profile $AWS_PROFILE

export MODEL_S3_URI=s3://$ARTIFACT_BUCKET/models/lstm/model.tar.gz


## 4. IAM Role
The role SMExecutiojnRoleFoodForecast was created with:
Trust policy allowing SageMaker to assume the role.
Attached policies:
AmazonSageMakerFullAccess
AmazonS3ReadOnlyAccess
Inline least-privilege S3 read policy scoped to the artifact bucket.
Permissions boundary removed to allow S3 access.


## 5. Deply Endpoint 

export SAGEMAKER_ROLE_ARN=$(aws iam get-role \
  --role-name $ROLE_NAME \
  --query 'Role.Arn' --output text --profile $AWS_PROFILE)

export ENDPOINT_NAME=food-forecast-lstm-v2

python - <<'PY'
import os, boto3, sagemaker
from sagemaker import image_uris
from sagemaker.tensorflow.model import TensorFlowModel

region = os.environ["AWS_REGION"]
role = os.environ["SAGEMAKER_ROLE_ARN"]
model_data = os.environ["MODEL_S3_URI"]
endpoint_name = os.environ["ENDPOINT_NAME"]

instance_type = "ml.c5.large"

sess = sagemaker.Session(boto_session=boto3.Session(region_name=region))
image = image_uris.retrieve(
    framework="tensorflow", region=region, version="2.13",
    image_scope="inference", instance_type=instance_type
)

m = TensorFlowModel(model_data=model_data, role=role,
                    framework_version="2.13", image_uri=image,
                    sagemaker_session=sess)

m.deploy(initial_instance_count=1,
         instance_type=instance_type,
         endpoint_name=endpoint_name)
print("Deployed endpoint:", endpoint_name)
PY


## 6. Smoke Test 

python - <<'PY'
import os, json, numpy as np, boto3

rt = boto3.client("sagemaker-runtime", region_name="us-east-1")
TIMESTEPS, N_FEATURES = 30, 1
x = np.random.rand(1, TIMESTEPS, N_FEATURES).tolist()

resp = rt.invoke_endpoint(
    EndpointName=os.environ["ENDPOINT_NAME"],
    ContentType="application/json",
    Body=json.dumps({"instances": x})
)
print("Prediction:", resp["Body"].read().decode())
PY


Example Output 

Prediction: {"predictions": [[0.363672316]]}

## 7. Monitoring

- Logs: Available in CloudWatch under /aws/sagemaker/Endpoints/<endpoint-name>.
- Metrics: Track invocation count, latency, and errors in the SageMaker console.
- Troubleshooting: Common issues include IAM permission errors, unsupported instance types, and S3 access restrictions.


## 8. Clean Up
Delete endpoint, config, and model to stop billing:


aws sagemaker delete-endpoint \
  --endpoint-name $ENDPOINT_NAME \
  --profile $AWS_PROFILE --region $AWS_REGION

aws sagemaker delete-endpoint-config \
  --endpoint-config-name $ENDPOINT_NAME \
  --profile $AWS_PROFILE --region $AWS_REGION

aws sagemaker delete-model \
  --model-name $ENDPOINT_NAME \
  --profile $AWS_PROFILE --region $AWS_REGION

# Architecture Overview

Pipeline:

Local model (.h5) → converted to .keras → exported as SavedModel → packaged as model.tar.gz → uploaded to S3 → SageMaker TensorFlow Serving container → deployed endpoint (ml.c5.large) → client requests with JSON → predictions returned in real-time.

                   +-------------------+
                   |   Local Training  |
                   |   (LSTM in .h5)   |
                   +---------+---------+
                             |
                             v
                   +-------------------+
                   | Convert to .keras |
                   | Export SavedModel |
                   +---------+---------+
                             |
                             v
                   +-------------------+
                   |  Package as .tar  |
                   |  Upload to S3     |
                   | (Artifact Bucket) |
                   +---------+---------+
                             |
                             v
                   +-------------------+
                   | SageMaker Service |
                   |  TensorFlow 2.13  |
                   |  Hosting Container|
                   +---------+---------+
                             |
                             v
                   +-------------------+
                   |  Deployed Endpoint|
                   | (ml.c5.large)     |
                   +---------+---------+
                             |
                             v
                   +-------------------+
                   |   Client Request  |
                   | (JSON Input 30x1) |
                   +---------+---------+
                             |
                             v
                   +-------------------+
                   |  Real-Time Output |
                   |  Predictions       |
                   +-------------------+


# Summary
This deployment successfully demonstrates the end-to-end process of taking production-ready code into a production environment. A legacy .h5 model was converted to TensorFlow .keras, exported as a SavedModel, packaged, and stored in S3. The model was then deployed using AWS SageMaker with the managed TensorFlow Serving 2.13 container, ensuring the application is fully 
containerized.

All requests to the live endpoint follow a clearly documented API schema and return predictions in real time. Endpoint logs and metrics are automatically captured in Amazon CloudWatch, providing visibility for monitoring and debugging. Cleanup steps are included to ensure cost control.

This process meets the deployment requirements of the capstone by showing:

1. A reproducible data and deployment pipeline (local → S3 → SageMaker).
2. Proper containerization via SageMaker’s managed TensorFlow Serving image.
3. Monitoring and logging through CloudWatch.
4. A tested, documented API returning sensible results.
   
The application is stable, extensible, and can be scaled by increasing instance size or replica count as needed.






