import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:cursoManguinhos/data/http/http_client.dart';

class ClientSpy extends Mock implements Client {}

class HttpAdapter implements HttpClient {
  final Client client;

  HttpAdapter(this.client);
  Future<Map> request({
    @required String url,
    @required String method,
    Map body,
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json'
    };
    final jsonBody = body != null ? jsonEncode(body) : null;
    final response = await client.post(
      url,
      headers: headers,
      body: jsonBody,
    );
    if (response.statusCode == 200) {
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } else {
      return null;
    }
  }
}

main() {
  ClientSpy client;
  HttpAdapter sut;
  String url;
  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client);

    url = faker.internet.httpUrl();
  });

  group('post', () {
    PostExpectation mockRequest() => when(
          client.post(
            any,
            body: anyNamed('body'),
            headers: anyNamed('headers'),
          ),
        );

    void mockResponse(int statusCode, {body = '{"any_key":"any_value"}'}) {
      mockRequest().thenAnswer((_) async => Response(body, statusCode));
    }

    setUp(() {
      mockResponse(200);
    });
    test('Should call post with correct values', () async {
      await sut
          .request(url: url, method: 'post', body: {'any_key': 'any_value'});

      verify(
        client.post(
          url,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json'
          },
          body: '{"any_key":"any_value"}',
        ),
      );
    });

    test('Should call post without body', () async {
      await sut.request(
        url: url,
        method: 'post',
        // body: {'any_key': 'any_value'},
      );

      verify(
        client.post(
          any,
          headers: anyNamed('headers'),
          // body: '{"any_key":"any_value"}',
        ),
      );
    });

    test('Should return data with post return 200', () async {
      final response = await sut.request(
        url: url,
        method: 'post',
        // body: {'any_key': 'any_value'},
      );

      expect(response, {"any_key": "any_value"});
    });

    test('Should return null with post return 200 ', () async {
      mockResponse(200, body: '');

      final response = await sut.request(
        url: url,
        method: 'post',
        // body: {'any_key': 'any_value'},
      );

      expect(response, null);
    });

    test('Should return null with post return 204', () async {
      mockResponse(204, body: '');

      final response = await sut.request(
        url: url,
        method: 'post',
        // body: {'any_key': 'any_value'},
      );

      expect(response, null);
    });

    test('Should return null with post return 204 with data', () async {
      mockResponse(204);

      final response = await sut.request(
        url: url,
        method: 'post',
        // body: {'any_key': 'any_value'},
      );

      expect(response, null);
    });
  });
}
