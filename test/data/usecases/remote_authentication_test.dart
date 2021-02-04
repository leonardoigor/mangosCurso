import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:cursoManguinhos/domain/usecases/usecases.dart';
import 'package:cursoManguinhos/data/usecases/usecases.dart';
import 'package:cursoManguinhos/domain/helpers/helpers.dart';

import 'package:cursoManguinhos/data/http/http.dart';

class HttpClientSpy extends Mock implements HttpClient {}

main() {
  HttpClientSpy httpClient;
  String url;
  RemoteAuthentication sut;
  AuthenticationParams params;
  PostExpectation mockRequest() => when(
        httpClient.request(
          url: anyNamed('url'),
          method: anyNamed('method'),
          body: anyNamed('body'),
        ),
      );
  Map mockValidData() => {
        'accessToken': faker.guid.guid(),
        'name': faker.person.name(),
      };
  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
        email: faker.internet.email(), secret: faker.internet.password());

    mockHttpData(mockValidData());
  });

  test('Should call httpClient with correct URL', () async {
    sut.auth(params);

    verify(httpClient.request(
      url: url,
      method: 'post',
      body: {'email': params.email, 'password': params.secret},
    ));
    // expect(sut, matcher);
  });

  test('Should throw UnexpectedError if Httpclint returns 400', () async {
    mockHttpError(HttpError.badRequest);

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if Httpclint returns 404', () async {
    mockHttpError(HttpError.notFound);

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if Httpclint returns 500', () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if Httpclint returns 401',
      () async {
    mockHttpError(HttpError.anauthorized);

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should return an account if httpclient returns 200', () async {
    final validData = mockValidData();
    mockHttpData(validData);

    final account = await sut.auth(params);
    expect(
      account.token,
      validData['accessToken'],
    );
  });

  test(
      'Should throw UnexpectedError if httpclient returns 200 with invalid data',
      () async {
    mockHttpData({
      'invalid_key': 'invalid_value',
      'name': faker.person.name(),
    });
    final future = sut.auth(params);
    expect(future, throwsA(DomainError.unexpected));
  });
}
