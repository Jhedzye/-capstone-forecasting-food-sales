
# Executive Summary
This project demonstrates deploying an LSTM-based forecasting model for food vendor sales to AWS SageMaker.  
The workflow includes converting a legacy `.h5` model to a modern TensorFlow SavedModel, packaging and storing it in S3, configuring IAM for secure access, and deploying the model to a managed TensorFlow Serving container.  
A live endpoint was created and tested with real-time predictions, completing the deployment phase of the capstone project.

---

# Quick Start 

### 0) Repo + Python venv
```bash
cd ~/capstone-forecasting-food-sales
python3.11 -m venv .venv
source .venv/bin/activate

### 1) Environment
export AWS_PROFILE=capstone
export AWS_REGION=us-east-1
export ARTIFACT_BUCKET=food-forecast-artifacts-jedda-123
export ROLE_NAME=SMExecutionRoleFoodForecast
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


### 9) Cleanup 
aaws sagemaker delete-endpoint --endpoint-name "$ENDPOINT_NAME" \
  --profile $AWS_PROFILE --region $AWS_REGION
aws sagemaker delete-endpoint-config --endpoint-config-name "$ENDPOINT_NAME" \
  --profile $AWS_PROFILE --region $AWS_REGION
aws sagemaker delete-model --model-name "$ENDPOINT_NAME" \
  --profile $AWS_PROFILE --region $AWS_REGION



# Detailed Deployment Steps 

## Forecasting Food Sales – SageMaker Deployment
This project demonstrates deploying an LSTM model for food vendor sales forecasting to an AWS SageMaker endpoint. The workflow covers model conversion, packaging, S3 upload, IAM configuration, endpoint deployment, prediction testing, monitoring, and cleanup.


## 1. Environment Setup

(See Quick Start)


## 2. Convert and Export Model
(See Quick Start)

## 3. Package and Upload to S3
(See Quick Start)


## 4. IAM Role
The role SMExecutionRoleFoodForecast was created with:
- Trust policy allowing SageMaker to assume the role.
- Policies: AmazonSageMakerFullAccess, AmazonS3ReadOnlyAccess.
- Inline least-privilege policy scoped to the artifact bucket.


## 5. Deply Endpoint 
(See Quick Start)

## 6. Smoke Test 

Example Output 


{"predictions": [[0.363672316]]}


## 7. Monitoring


Logs: CloudWatch /aws/sagemaker/Endpoints/<endpoint-name>
Metrics: invocation count, latency, errors
Troubleshooting: IAM permission errors, instance type limits, S3 issues


## 8. Clean Up
(See Quick Start)

# Architecture Overview

Pipeline:

Local .h5 → .keras → SavedModel → tar.gz → S3
→ SageMaker TensorFlow Serving 2.13 → Endpoint (ml.c5.large)
→ Client JSON request → Real-time prediction
.

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




## Run & Deployment

### Local Run

export AWS_REGION=us-east-1
export ENDPOINT_NAME=food-forecast-lstm-v2
export TIMESTEPS=30
export N_FEATURES=1

python3 app.py

Open http://127.0.0.1:8000 in your browser to test the UI.

---

### Deploy
Create an endpoint with:
```bash
bash deploy/create_endpoint.sh

### Tear Down


bash deploy/delete_endpoint.sh




### Environment Variables 

This project uses .env.example for quick setup.

cp .env.example .env

Edit .env to match your SageMaker settings.

___
### Repo Structure 

├── app.py                  # Flask app (UI + endpoint proxy)
├── inference.py            # Inference helpers
├── deploy/                 # Scripts for endpoint management
│   ├── create_endpoint.sh
│   ├── delete_endpoint.sh
├── requirements.txt        # Dependencies
├── .env.example            # Example env file




### Troubleshooting

- If git push or AWS CLI commands hang, reset credentials and try again.
- If Flask doesn’t start, confirm .venv is active and requirements.txt installed.






## Screenshots

### Flask UI running locally
![Flask UI](./screenshoots/flask_ui.png)

### Endpoint deployed in AWS SageMaker Console
![SageMaker Endpoint](./screenshoots/endpoint_Inservice.png)


















