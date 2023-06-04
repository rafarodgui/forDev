import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fordev/domain/helpers/helpers.dart';
import 'package:fordev/data/usecases/usecases.dart';
import 'package:fordev/data/http/http.dart';

import 'package:fordev/domain/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late HttpClientSpy httpClient = HttpClientSpy();
  late RemoteAuthentication sut;
  String url = '';
  late AuthenticationParams params;

  Map mockValidData() => {
        'accessToken': faker.guid.guid(),
        'name': faker.person.name(),
      };

  When mockRequest() => when(
        () => httpClient.request(
          url: any(named: 'url'),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      );

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(
    () {
      httpClient = HttpClientSpy();
      url = faker.internet.httpUrl();
      sut = RemoteAuthentication(httpClient: httpClient, url: url);
      params = AuthenticationParams(
        email: faker.internet.email(),
        secret: faker.internet.password(),
      );
      mockHttpData(mockValidData());
    },
  );

  test(
    'Should call HttpClient with correct values',
    () async {
      await sut.auth(params);

      verify(
        () => httpClient.request(
          url: url,
          method: 'post',
          body: {
            'email': params.email,
            'password': params.secret,
          },
        ),
      );
    },
  );

  test(
    'Should throw UnexpectedError if HttpCliente returns status 400',
    () async {
      mockHttpError(HttpError.badRequest);

      final future = sut.auth(params);

      expect(future, throwsA(DomainError.unexpected));
    },
  );

  test(
    'Should throw UnexpectedError if HttpCliente returns status 404',
    () async {
      mockHttpError(HttpError.notFound);

      final future = sut.auth(params);

      expect(future, throwsA(DomainError.unexpected));
    },
  );

  test(
    'Should throw UnexpectedError if HttpCliente returns status 500',
    () async {
      mockHttpError(HttpError.serverError);

      final future = sut.auth(params);

      expect(future, throwsA(DomainError.unexpected));
    },
  );

  test(
    'Should throw invalidCredentialsError if HttpCliente returns status 401',
    () async {
      mockHttpError(HttpError.unauthorized);

      final future = sut.auth(params);

      expect(future, throwsA(DomainError.invalidCredentials));
    },
  );

  test(
    'Should return AccountEntity if HttpClient returns 200',
    () async {
      final validData = mockValidData();
      mockHttpData(validData);

      final account = await sut.auth(params);

      expect(account.token, validData['accessToken']);
    },
  );

  test(
    'Should throw UnexpectedError if HttpClient returns 200 with incorrect data',
    () async {
      mockHttpData({'invalid_key': 'invalid_value'});

      final future = sut.auth(params);

      expect(future, throwsA(DomainError.unexpected));
    },
  );
}
