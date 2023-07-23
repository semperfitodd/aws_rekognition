# AWS Rekognition Proof-of-Concept with AWS Lambda and DynamoDB
## Table of Contents
[1. Introduction](#1-introduction)

[2. Prerequisites](#2-prerequisites)

[3. Deployment Steps](#3-deployment-steps)

- [3.1 Initial Setup](#31-initial-setup)

- [3.2 Uploading Images to S3](#32-uploading-images-to-s3)

[4. Testing](#4-testing)

[5. Important Considerations](#5-important-considerations)

[6. Clean Up](#6-clean-up)
## 1. Introduction
This README explains the steps to deploy a proof-of-concept (POC) that integrates AWS Lambda, AWS Rekognition, and DynamoDB. The architecture is provisioned using Terraform. Upon successful deployment, the system will process images uploaded to an S3 bucket, apply image recognition with AWS Rekognition, and store the results in DynamoDB.

## 2. Prerequisites
- AWS account
- Terraform v0.14 or later
- AWS CLI installed and configured
## 3. Deployment Steps
### 3.1 Initial Setup
1. Clone the repository and navigate to the terraform directory.
    ```bash
    git clone https://github.com/semperfitodd/aws_rekognition.git
    cd aws_rekognition/terraform
   ```
2. Initialize Terraform.
    ```bash
    terraform init
    ```
3. Apply Terraform plan. The output includes the name of the S3 bucket.
    ```bash
    terraform plan -out=plan.out
    terraform apply plan.out
    ```
Take note of the S3 bucket name from the output.
![output.png](img%2Foutput.png)
### 3.2 Uploading Images to S3
Navigate back to the root directory of the project.
```bash
cd ..
```
Upload the images to the S3 bucket using the AWS CLI. Replace <your-bucket-name> with the name of the bucket outputted from the terraform apply command.
```bash
aws s3 sync . s3://<BUCKET_NAME>
```
![cli_sync.png](img%2Fcli_sync.png)
## 4. Testing
You can test the functionality by checking the DynamoDB table for results of image recognition after you've uploaded the images.
![dynamo.png](img%2Fdynamo.png)
## 5. Important Considerations
- Ensure your AWS CLI is configured with the right access permissions to interact with S3, Lambda, Rekognition, and DynamoDB.
- Cost: AWS Lambda, S3, Rekognition, and DynamoDB are not free services. Be mindful of potential costs.
## 6. Clean Up
To avoid unnecessary charges, clean up the resources after you've finished testing.

```bash
terraform destroy -auto-approve
```