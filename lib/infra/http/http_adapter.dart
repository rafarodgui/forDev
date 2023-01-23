import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../../data/http/http.dart';

class HttpAdapter implements HttpClient {
  final Client client;

  HttpAdapter(this.client);

  Future<Map> request({
    @required String url,
    @required String method,
    Map body,
  }) async {
    final headers = {
      'content-type': 'aplication/json',
      'accept': 'aplication/json',
    };
    final verifyBodyExists = body != null ? jsonEncode(body) : null;
    final response = await client.post(Uri.parse(url), headers: headers, body: verifyBodyExists);

    if (response.statusCode == 204) return null;

    return response.body.isEmpty ? null : jsonDecode(response.body);
  }
}
