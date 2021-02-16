import 'package:flutter/material.dart';

import 'package:cursoManguinhos/ui/components/components.dart';
import 'package:cursoManguinhos/ui/pages/login/login_presenter.dart';
import 'package:provider/provider.dart';

import 'components/components.dart';

class LoginPage extends StatefulWidget {
  final LoginPresenter presenter;
  const LoginPage({
    Key key,
    @required this.presenter,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void dispose() {
    widget.presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (ctx) {
          widget.presenter.mainerrorStream.listen((error) {
            if (error != null) {
              showErrorMessage(ctx, error);
            }
          });

          widget.presenter.isLoading.listen((isLoading) {
            if (isLoading) {
              showLoading(context);
            } else {
              hideLoading(context);
            }
          });

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LoginHeaader(),
                HeadLine1(text: 'login'),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Provider(
                    create: (context) => widget.presenter,
                    child: Form(
                      child: Column(
                        children: [
                          EmailInput(),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 32,
                            ),
                            child: PasswordInput(),
                          ),
                          LoginButton(),
                          FlatButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.person),
                              label: Text('Criar Conta'))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
