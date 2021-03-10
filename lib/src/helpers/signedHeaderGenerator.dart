import 'package:crypto/crypto.dart';
import 'dart:convert';

Digest sign(key,message){
var hmac =Hmac(sha256, key);
var bytes = utf8.encode(message);
var digest = hmac.convert(bytes);
return digest;
}


List<int> getSignatureKey(key,dateStamp,regionName,serviceName){
  var kSecret = utf8.encode('AWS4'+key);
  var kDate = sign(kSecret,dateStamp);
  var kRegion = sign(kDate.bytes,regionName);
  var kService = sign(kRegion.bytes,serviceName);
  var kSigning = sign(kService.bytes,'aws4_request');
  return kSigning.bytes;
}

String zeroAppender(number) => number<10?'0$number':'$number';

Map<String,String> generateDateStamps(){
final now = DateTime.now().toUtc();
final day = zeroAppender(now.day);
final month = zeroAppender(now.month);
final year = now.year;
final hour = zeroAppender(now.hour);
final minute = zeroAppender(now.minute);
final second = zeroAppender(now.second);
final amzDate = '$year$month${day}T$hour$minute${second}Z';
final dateStamp = '$year$month$day';

return {
  'amzDate': amzDate,
  'dateStamp': dateStamp
};
}


Map<String,String> generateHeaders(
  String service,
  String host,
  String region,
  String endpoint,
  String method,
  String requestParams,
  String amzTarget,
  String accessKey,
  String secretKey
  ){
final contentType = 'application/x-amz-json-1.0';
final dateStampsMap = generateDateStamps();
final amzDate = dateStampsMap['amzDate'];
final dateStamp = dateStampsMap['dateStamp'];


// create canonical request
final canonicalUri = '/';
final canonicalQuerystring = '';
final canonicalHeaders = 'content-type:' + contentType + '\n' + 'host:' + host + '\n' + 'x-amz-date:' + amzDate + '\n' + 'x-amz-target:' + amzTarget + '\n';
final signedHeaders = 'content-type;host;x-amz-date;x-amz-target';
final requestParamsEncoded = utf8.encode(requestParams);
final payloadHash = sha256.convert(requestParamsEncoded).toString();
final canonicalRequest = method + '\n' + canonicalUri + '\n' + canonicalQuerystring + '\n' + canonicalHeaders + '\n' + signedHeaders + '\n' + payloadHash;



// create string to sign
final algorithm = 'AWS4-HMAC-SHA256';
final credentialScope = dateStamp + '/' + region + '/' + service + '/' + 'aws4_request';
final encodedCanonicalRequest = utf8.encode(canonicalRequest);
final hash = sha256.convert(encodedCanonicalRequest).toString();
final stringToSign = algorithm + '\n' +  amzDate + '\n' +  credentialScope + '\n' +  hash;


// calculate signature
final signingKey = getSignatureKey(secretKey, dateStamp, region, service);
final encodedStringToSign = utf8.encode(stringToSign);
var hmac = Hmac(sha256,signingKey);
final signature = hmac.convert(encodedStringToSign).toString();

// create signed headers
final authorizationHeader = algorithm + ' ' + 'Credential=' + accessKey + '/' + credentialScope + ', ' +  'SignedHeaders=' + signedHeaders + ', ' + 'Signature=' + signature;
final headers = {
  'Content-Type': contentType,
  'X-Amz-Date': amzDate,
  'X-Amz-Target': amzTarget,
  'Authorization': authorizationHeader,
  'host': host
};

return headers;
}