import 'package:meta/meta.dart';

import '../../domain/usecases/usecases.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/helpers/domain_error.dart';

import '../http/http.dart';

import 'package:cursoManguinhos/data/models/models.dart';

class RemoteAuthentication implements Authentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({
    @required this.httpClient,
    @required this.url,
  });

  Future<AccountEntity> auth(AuthenticationParams params) async {
    final body = RemoteAuthenticationParams.fromDomain(params).toMap();
    try {
      final httpResponse = await httpClient.request(
        url: url,
        method: 'post',
        body: body,
      );

      return RemoteAccountModel.fromMap(httpResponse).toEntity();
    } on HttpError catch (error) {
      throw error == HttpError.unauthorized
          ? DomainError.invalidCredentials
          : DomainError.unexpected;
    }
  }
}

class RemoteAuthenticationParams {
  final String email;
  final String password;
  RemoteAuthenticationParams({
    @required this.email,
    @required this.password,
  });

  factory RemoteAuthenticationParams.fromDomain(AuthenticationParams parans) =>
      RemoteAuthenticationParams(email: parans.email, password: parans.secret);

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }
}
