import 'package:dart_aws_request/dart_aws_request.dart';

void main() async {
  final accessKey = 'yourkey';
  final secretKey = 'yoursecret';
  final amzTarget = 'DynamoDB_20120810.DeleteItem';
  final service = 'dynamodb';
  final host = 'dynamodb.ap-south-1.amazonaws.com';
  final region = 'ap-south-1';
  final endpoint = 'https://dynamodb.ap-south-1.amazonaws.com/';
  final method = 'POST';

  final requestBody = {
      'TableName': 'someTable',
      'Key': {
          'Name' : {
              'S': 'someName'
          },
          'Age': {
              'S': '25'
          }
      },
      'ReturnConsumedCapacity': 'TOTAL'
  };

  final awsClient = AWSRequest(accessKey, secretKey);

  // if you need just the headers, to use with your own http client
  final headers = awsClient.generateSignedHeaders(
      service,
      host,
      region,
      endpoint,
      method,
      requestBody,
      amzTarget
    );

  // if you want to make the request
  final responseJson = await awsClient.postRequest(service,
      host,
      region,
      endpoint,
      method,
      requestBody,
      amzTarget
    );
  
  print(responseJson);
}
