import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/pages/account_deletion_page.dart';
import 'package:luckez/services/auth_service.dart';

void main() {
  testWidgets('Google account verifies without password fields',
      (tester) async {
    var googleRequests = 0;
    await tester.pumpWidget(MaterialApp(
      home: AccountDeletionPage(
        onVerify: (_, password) async => fail('Password must not be used'),
        onGoogleVerify: () async {
          googleRequests++;
        },
      ),
    ));
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Google로 본인 확인'));
    await tester.pumpAndSettle();
    expect(googleRequests, 1);
    expect(find.text('정말 탈퇴하시겠어요?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '취소').last);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Password verification opens confirmation before proceeding',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AccountDeletionPage(onVerify: (email, password) async {}),
    ));
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.ensureVisible(find.text('탈퇴'));
    await tester.tap(find.text('탈퇴'));
    await tester.pumpAndSettle();
    expect(find.text('정말 탈퇴하시겠어요?'), findsOneWidget);
    await tester.tap(find.text('탈퇴하기'));
    await tester.pumpAndSettle();
    expect(find.text('회원 탈퇴 기능은 준비 중이에요'), findsOneWidget);
  });

  testWidgets('Cancellation is silent and another account shows an error',
      (tester) async {
    var cancel = true;
    await tester.pumpWidget(MaterialApp(
      home: AccountDeletionPage(
        onVerify: (_, password) async {},
        onGoogleVerify: () async {
          if (cancel) throw const AuthCancelledException();
          throw FirebaseAuthException(code: 'user-mismatch');
        },
      ),
    ));
    await tester.tap(find.text('Google로 본인 확인'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    cancel = false;
    await tester.tap(find.text('Google로 본인 확인'));
    await tester.pumpAndSettle();
    expect(find.text('현재 로그인한 Google 계정을 선택해주세요'), findsOneWidget);
  });
}
