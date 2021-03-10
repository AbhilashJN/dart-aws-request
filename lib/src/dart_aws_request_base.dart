
import 'dart:convert';
import './helpers/signedHeaderGenerator.dart';
import './helpers/httpHelper.dart';

/// Creates an AWSRequest object with the given keys
class AWSRequest {
  final String _accessKeyID;
  final String _secretAccessKey;
  AWSRequest(this._accessKeyID, this._secretAccessKey);


  /// Generates the signed headers, which can then be used with any HTTP client
  Map<String,String> generateSignedHeaders(
    String service,
    String host,
    String region,
    String endpoint,
    String method,
    Map requestBody,
    String amzTarget
  ){
    final requestBodyString = json.encode(requestBody);
    return generateHeaders(
      service, 
      host, 
      region, 
      endpoint, 
      method, 
      requestBodyString, 
      amzTarget,
      _accessKeyID,
      _secretAccessKey);
  }


  /// Generates signed headers, makes the POST request, and returns the JSON response
  Future postRequest(
    String service,
    String host,
    String region,
    String endpoint,
    String method,
    Map requestBody,
    String amzTarget
  ) async {
    final requestBodyString = json.encode(requestBody);
    final headers = generateHeaders(
      service, 
      host, 
      region, 
      endpoint, 
      method, 
      requestBodyString, 
      amzTarget,
      _accessKeyID,
      _secretAccessKey);

    final responseJson = await httpPost(endpoint, headers, requestBody);
    return responseJson;
  }
}
