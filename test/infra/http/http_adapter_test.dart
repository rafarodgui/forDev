import 'package:faker/faker.dart';
import 'package:fordev/data/http/http.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../mocks/mocks.dart';

import 'package:fordev/infra/http/http.dart';

void main() {
  late HttpAdapter sut;
  late ClientSpy client;
  late String url;

  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client);
  });

  setUpAll(() {
    url = faker.internet.httpUrl();
    registerFallbackValue(Uri.parse(url));
  });

  group('post', () {
    When mockRequest() => when(
          () => client.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        );

    void mockResponse(int statusCode,
        {String body = '{"any_key":"any_value"}'}) {
      mockRequest().thenAnswer((_) async => Response(body, statusCode));
    }

    setUp(() => {
          mockResponse(200),
        });

    test('shoul call post with correct values', () async {
      await sut
          .request(url: url, method: 'post', body: {'any_key': 'any_value'});

      verifyNever(() => client.post(
            Uri.parse(url),
            headers: {
              'content-type': 'aplication/json',
              'accept': 'aplication/json'
            },
            body: '{"any_key":"any_value"}',
          ));
    });

    test('shoul call post without body', () async {
      await sut.request(url: url, method: 'post');

      verify(() => client.post(any(), headers: any(named: 'headers')));
    });

    test('should return data if post return 200', () async {
      final response = await sut.request(url: url, method: 'post');

      expect(response, {"any_key": "any_value"});
    });

    test('should return null if post return 200', () async {
      client.mockPost(200, body: '');

      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });

    test('shoul return null if post return 204', () async {
      client.mockPost(204, body: '');

      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });

    test('shoul return null if post return 204 with data', () async {
      client.mockPost(204);

      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });

    test('should return BadRequest error if post retuns 400 without body',
        () async {
      mockResponse(400, body: '');

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('shoul return BadRequest error if post retuns 400', () async {
      mockResponse(400);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('shoul return ServerError error if post retuns 500', () async {
      mockResponse(500);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.serverError));
    });
  });
}
