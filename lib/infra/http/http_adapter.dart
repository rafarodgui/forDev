import 'dart:convert';

import 'package:http/http.dart';

import '../../data/http/http.dart';

class HttpAdapter implements HttpClient {
  final Client client;

  HttpAdapter(this.client);

  Future<dynamic> request({
    required String url,
    required String method,
    Map? body,
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final verifyBodyExists = body != null ? jsonEncode(body) : null;
    final response = await client.post(Uri.parse(url),
        headers: headers, body: verifyBodyExists);

    return _handleResponse(response);
  }

  _handleResponse(Response response) {
    if (response.statusCode == 200) {
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      throw HttpError.badRequest;
    } else {
      return null;
    }
  }
}
