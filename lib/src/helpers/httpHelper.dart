import 'dart:io';
import 'dart:convert';
  
Future httpPost(endpoint,headers,body) async {
  HttpClient.enableTimelineLogging = true;
  final httpClient = HttpClient();
  final request = await httpClient.postUrl(Uri.parse(endpoint));
  headers.forEach((key, value) {
    request.headers.set(key,value);
  });
  request.add(utf8.encode(jsonEncode(body)));

  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  final responseJson = jsonDecode(responseBody);
  return responseJson;
}
