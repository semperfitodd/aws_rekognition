import json
import boto3
import os


def lambda_handler(event, context):
    s3_info = event['Records'][0]['s3']
    bucket_name = s3_info['bucket']['name']
    file_name = s3_info['object']['key']

    rekognition_client = boto3.client('rekognition')
    response = rekognition_client.detect_labels(Image={'S3Object': {'Bucket': bucket_name, 'Name': file_name}},
                                                MaxLabels=10)

    print('Detected labels for ' + file_name)
    dynamodb = boto3.resource('dynamodb')

    # Get the table name from the environment variable
    table_name = os.environ['DYNAMODB_TABLE']
    table = dynamodb.Table(table_name)

    # Create a list of maps for labels
    labels = [{'Name': label['Name'], 'Confidence': str(label['Confidence'])} for label in response['Labels']]

    # Write all labels to a single DynamoDB item
    table.put_item(
        Item={
            'FileName': file_name,
            'Labels': labels
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Image processed!')
    }
