import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/pages/password_reset_page.dart';

void main() {
  testWidgets('Invalid email does not send a request', (tester) async {
    var requests = 0;
    await tester.pumpWidget(MaterialApp(
      home: PasswordResetPage(onSubmit: (_) async => requests++),
    ));
    await tester.tap(find.text('재설정 메일 보내기'));
    await tester.pump();
    expect(find.text('이메일을 입력해주세요'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'invalid');
    await tester.tap(find.text('재설정 메일 보내기'));
    await tester.pump();
    expect(find.text('올바른 이메일 주소를 입력해주세요'), findsOneWidget);
    expect(requests, 0);
  });

  testWidgets('Prefills email and disables requests while sending',
      (tester) async {
    final request = Completer<void>();
    String? submittedEmail;
    await tester.pumpWidget(MaterialApp(
      home: PasswordResetPage(
        initialEmail: 'test@example.com',
        onSubmit: (email) {
          submittedEmail = email;
          return request.future;
        },
      ),
    ));
    await tester.tap(find.text('재설정 메일 보내기'));
    await tester.pump();
    expect(submittedEmail, 'test@example.com');
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    request.complete();
    await tester.pumpAndSettle();
    expect(find.text('로그인으로 돌아가기'), findsOneWidget);
  });
}
