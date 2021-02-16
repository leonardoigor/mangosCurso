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
  StreamController<String> passwordErrorController;
  StreamController<String> mainErrorController;
  StreamController<bool> isFormValiddErrorController;
  StreamController<bool> isLoadingController;

  void initStreams() {
    emailErrorController = StreamController<String>();
    passwordErrorController = StreamController<String>();
    mainErrorController = StreamController<String>();
    isFormValiddErrorController = StreamController<bool>();
    isLoadingController = StreamController<bool>();
  }

  void mockStreams() {
    when(presenter.emailErrorStream)
        .thenAnswer((_) => emailErrorController.stream);
    when(presenter.passwordErrorStream)
        .thenAnswer((_) => passwordErrorController.stream);
    when(presenter.isFormErrorStream)
        .thenAnswer((_) => isFormValiddErrorController.stream);
    when(presenter.isLoading).thenAnswer((_) => isLoadingController.stream);

    when(presenter.mainerrorStream)
        .thenAnswer((_) => mainErrorController.stream);
  }

  void closeStream() {
    emailErrorController.close();
    passwordErrorController.close();
    isLoadingController.close();
    isFormValiddErrorController.close();
    mainErrorController.close();
  }

  Future loadPage(WidgetTester tester) async {
    presenter = LoginPresenterSpy();
    initStreams();
    mockStreams();
    final loginPage = MaterialApp(
      home: LoginPage(
        presenter: presenter,
      ),
    );
    await tester.pumpWidget(loginPage);
  }

  tearDown(() {
    closeStream();
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
    expect(find.byType(CircularProgressIndicator), findsNothing);

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
  testWidgets('should present errror if email is invalid',
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

  testWidgets('should present errror if passwor is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController.add(null);
    await tester.pump();

    expect(
      find.descendant(
        of: find.bySemanticsLabel('Email'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('should present errror if password is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController.add('any error');
    await tester.pump();

    expect(find.text('any error'), findsOneWidget);
  });
  testWidgets('should present errror if password is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController.add('');
    await tester.pump();

    expect(
      find.descendant(
        of: find.bySemanticsLabel('Senha'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });
  testWidgets('should anable form button if form is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValiddErrorController.add(true);
    await tester.pump();
    final button = tester.widget<RaisedButton>(
      find.byType(RaisedButton),
    );
    expect(button.onPressed, isNotNull);
  });
  testWidgets('should disanable form button if form is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValiddErrorController.add(false);
    await tester.pump();
    final button = tester.widget<RaisedButton>(
      find.byType(RaisedButton),
    );
    expect(button.onPressed, isNull);
  });
  testWidgets('should present loading', (WidgetTester tester) async {
    await loadPage(tester);

    isFormValiddErrorController.add(true);
    await tester.pump();
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    verify(presenter.auth()).called(1);
  });
  testWidgets('should show loading', (WidgetTester tester) async {
    await loadPage(tester);

    isLoadingController.add(true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testWidgets('should hide loading', (WidgetTester tester) async {
    await loadPage(tester);

    isLoadingController.add(true);
    await tester.pump();
    isLoadingController.add(false);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
  testWidgets('should Presente errror message if authenticantion fails',
      (WidgetTester tester) async {
    await loadPage(tester);

    mainErrorController.add('main error');
    await tester.pump();
    expect(find.text('main error'), findsOneWidget);
  });
  testWidgets('should dispose all streams', (WidgetTester tester) async {
    await loadPage(tester);

    addTearDown(() {
      verify(presenter.dispose()).called(1);
    });
  });
}
