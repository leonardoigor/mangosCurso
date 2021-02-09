import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursoManguinhos/ui/pages/login/login_page.dart';

import 'package:cursoManguinhos/ui/pages/pages.dart';

class LoginPresenterSpy extends Mock implements LoginPresenter {}

main() {
  LoginPresenter presenter;
  StreamController<String> emailErrorController;

  Future loadPage(WidgetTester tester) async {
    presenter = LoginPresenterSpy();
    emailErrorController = StreamController<String>();

    when(presenter.emailErrorStream)
        .thenAnswer((_) => emailErrorController.stream);

    final loginPage = MaterialApp(
      home: LoginPage(
        presenter: presenter,
      ),
    );
    await tester.pumpWidget(loginPage);
  }

  tearDown(() {
    emailErrorController.close();
  });

  testWidgets('should load with correct initial state',
      (WidgetTester tester) async {
    await loadPage(tester);
    final emailTextChildren = find.descendant(
        of: find.bySemanticsLabel('Email'), matching: find.byType(Text));

    expect(
      emailTextChildren,
      findsOneWidget,
      reason:
          'when a textformFiled has only one text child, means it has no errors, since ne of the childs is always the hint label text!',
    );

    final passwordTextChildren = find.descendant(
        of: find.bySemanticsLabel('Senha'), matching: find.byType(Text));

    expect(
      passwordTextChildren,
      findsOneWidget,
      reason:
          'when a textformFiled has only one text child, means it has no errors, since ne of the childs is always the hint label text!',
    );

    final button = tester.widget<RaisedButton>(
      find.byType(RaisedButton),
    );

    expect(button.onPressed, null);
  });

  testWidgets('should call validade with correct value',
      (WidgetTester tester) async {
    await loadPage(tester);

    final emailTextChildren = find.bySemanticsLabel('Email');
    final email = faker.internet.email();
    await tester.enterText(emailTextChildren, email);
    verify(presenter.validateEmail(email));

    final passwordTextChildren = find.bySemanticsLabel('Senha');
    final pass = faker.internet.password();
    await tester.enterText(passwordTextChildren, pass);
    verify(presenter.validatePassword(pass));
  });

  testWidgets('should present errror if email is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    emailErrorController.add('any error');
    await tester.pump();

    expect(find.text('any error'), findsOneWidget);
  });
  testWidgets('should present errror if email is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    emailErrorController.add(null);
    await tester.pump();

    expect(
      find.descendant(
        of: find.bySemanticsLabel('Email'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });
  testWidgets('should present errror if email is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    emailErrorController.add('');
    await tester.pump();

    expect(
      find.descendant(
        of: find.bySemanticsLabel('Email'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });
}
