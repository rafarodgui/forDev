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
      await sut.request(url: url, method: 'post');

      verify(client.post(
        Uri.parse(url),
      ));
    });

    test('shoul call post with correct headers', () async {
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
