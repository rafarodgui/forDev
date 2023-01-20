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
  }) async {
    final headers = {
      'content-type': 'aplication/json',
      'accept': 'aplication/json',
    };
    await client.post(Uri.parse(url), headers: headers);
  }
}

class ClientSpy extends Mock implements Client {}

void main() {
  group('post', () {
    test('shoul call post with correct values', () async {
      final client = ClientSpy();
      final sut = HttpAdapter(client);
      final url = faker.internet.httpUrl();

      //action
      await sut.request(url: url, method: 'post');

      verify(client.post(
        Uri.parse(url),
      ));
    });

    test('shoul call post with correct headers', () async {
      final client = ClientSpy();
      final sut = HttpAdapter(client);
      final url = faker.internet.httpUrl();

      //action
      await sut.request(url: url, method: 'post');

      verify(client.post(
        Uri.parse(url),
        headers: {
          'content-type': 'aplication/json',
          'accept': 'aplication/json',
        },
      ));
    });
  });
}
