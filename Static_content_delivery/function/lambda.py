import boto3
import os
from botocore.exceptions import ClientError

# Initialize the S3 client
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Replace with your bucket name
    bucket_name = os.getenv('BUCKET_NAME')
    bucket_key = os.getenv('BUCKET_KEY')
    
    try:
        # Fetch the file from S3
        response = s3_client.get_object(Bucket=bucket_name, Key=bucket_key)
        
        # Read the content of the file (optional, depending on the use case)
        file_content = response['Body'].read()
        
        # Return the content with a Content-Type header set to text/html
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'text/html'
            },
            'body': file_content.decode('utf-8')  # Decode if it's a UTF-8 encoded HTML file
        }
        
    except ClientError as e:
        # Handle error, e.g., if file is not found
        return {
            'statusCode': 500,
            'body': str(e)
        }
