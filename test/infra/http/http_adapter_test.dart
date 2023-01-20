import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:meta/meta.dart';

class HttpAdapter {
  final Client client;

  HttpAdapter(this.client);

  Future<void> request({
    @required String url,
    @required String method,
    Map body,
  }) async {
    final headers = {
      'content-type': 'aplication/json',
      'accept': 'aplication/json',
    };
    final verifyBodyExists = body != null ? jsonEncode(body) : null;
    await client.post(Uri.parse(url), headers: headers, body: verifyBodyExists);
  }
}

class ClientSpy extends Mock implements Client {}

void main() {
  HttpAdapter sut;
  ClientSpy client;
  String url;

  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client);
    url = faker.internet.httpUrl();
  });

  group('post', () {
    test('shoul call post with correct values', () async {
      //action
      await sut.request(url: url, method: 'post', body: {'any_key': 'any_value'});

      verify(
        client.post(
          Uri.parse(url),
          headers: {
            'content-type': 'aplication/json',
            'accept': 'aplication/json',
          },
          body: '{"any_key":"any_value"}',
        ),
      );
    });

    test('shoul call post without body', () async {
      //action
      await sut.request(url: url, method: 'post');

      verify(
        client.post(
          any,
          headers: anyNamed('headers'),
        ),
      );
    });
  });
}
