import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final presenter = Provider.of<LoginPresenter>(context);

    return StreamBuilder<bool>(
        stream: presenter.isFormErrorStream,
        builder: (context, snapshot) {
          return RaisedButton(
            onPressed: snapshot.data == true ? presenter.auth : null,
            child: Text(
              'entrar'.toUpperCase(),
            ),
          );
        });
  }
}
