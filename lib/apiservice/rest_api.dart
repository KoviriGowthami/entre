import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class URLS {
  static const String BASE_URL =
      "http://portal.prospectatech.com/erp3.1webservices/v1";
      // "192.168.235.81/erp3.1webservices39/v1";
}

class Headers {
  static const Map<String, String> headers = {
    "Content-type": "application/json",
    "Authorization": "b8416f2680eb194d61b33f9909f94b9d"
  };
  static const Map<String, String> multipartheaders = {
    "Authorization": "b8416f2680eb194d61b33f9909f94b9d",
    "Content-type": "multipart/form-data"
  };
}

class ApiService {

  static Future<http.Response> post(url, body) async {
    try {
      final response = await http.post(Uri.parse('${URLS.BASE_URL}/${url}'),
          headers: {
            "Content-type": "application/json",
            "Authorization": "b8416f2680eb194d61b33f9909f94b9d"
          },
          body: body);
      return response;
    } catch (e) {
      // return e;
      print(e);
    }
  }

  static Future<http.Response> get(url) async {
    try {
      final response = await http.get(Uri.parse('${URLS.BASE_URL}/${url}'),
          headers: {
            "Content-type": "application/json",
            "Authorization": "b8416f2680eb194d61b33f9909f94b9d"
          });
      return response;
    } catch (e) {
      return e;
    }
  }

  static Future<String> makeUploadApi(String userId,String filePath) async {
    var postUri = Uri.parse('${URLS.BASE_URL}/profileImageUpload');
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'photofile', filePath);
    request.headers.addAll(Headers.multipartheaders);
    request.files.add(multipartFile);
    request.fields["user_id"] = userId;
    final response = await request.send();
    final api = await response.stream.bytesToString();
    return api.toString();
  }

  static  decodeResponse(response) async {
    var apiresponse = await Response.fromStream(response);
  }

    }