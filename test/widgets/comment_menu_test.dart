import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/models/community_comment.dart';
import 'package:luckez/models/community_post.dart';
import 'package:luckez/pages/community_post_detail_page.dart';
import 'package:luckez/repositories/community_repository.dart';

void main() {
  Future<void> openMenu(
    WidgetTester tester, {
    String? userId = 'author',
    bool isAdmin = false,
    VoidCallback? onLoginRequired,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: CommunityPostDetailPage(
        post: CommunityPost(
          id: 'post',
          title: 'Title',
          content: 'Content',
          authorId: 'post-author',
          authorName: 'Post author',
          commentCount: 1,
          likeCount: 0,
          createdAt: DateTime(2026, 1, 1),
        ),
        currentUserId: userId,
        currentUserName: 'User',
        isAdmin: isAdmin,
        onLoginRequired: onLoginRequired ?? () {},
        communityRepository: _TestRepository(),
      ),
    ));
    await tester.pumpAndSettle();
    final button = find.byTooltip('댓글 메뉴');
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('Own comment exposes edit, report and delete in one menu',
      (tester) async {
    await openMenu(tester);
    expect(find.text('수정'), findsOneWidget);
    expect(find.text('신고'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Other member can only report comment', (tester) async {
    await openMenu(tester, userId: 'other');
    expect(find.text('수정'), findsNothing);
    expect(find.text('삭제'), findsNothing);
    expect(find.text('신고'), findsOneWidget);
  });

  testWidgets('Admin can delete another comment but cannot edit it',
      (tester) async {
    await openMenu(tester, userId: 'admin', isAdmin: true);
    expect(find.text('수정'), findsNothing);
    expect(find.text('삭제'), findsOneWidget);
    expect(find.text('신고'), findsOneWidget);
  });

  for (final action in ['수정', '신고', '삭제']) {
    testWidgets('Selecting $action opens existing dialog', (tester) async {
      await openMenu(tester);
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
          find.text(switch (action) {
            '수정' => '댓글 수정',
            '신고' => '신고할까요?',
            _ => '댓글을 삭제할까요?',
          }),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Signed out report requests login instead of dialog',
      (tester) async {
    var loginRequests = 0;
    await openMenu(tester,
        userId: null, onLoginRequired: () => loginRequests++);
    await tester.tap(find.text('신고'));
    await tester.pumpAndSettle();
    expect(loginRequests, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });
}

class _TestRepository implements CommunityRepository {
  @override
  Stream<List<CommunityComment>> watchComments(String postId) => Stream.value([
        CommunityComment(
          id: 'comment',
          content: 'Comment content',
          authorId: 'author',
          authorName: 'Comment author',
          createdAt: DateTime(2026, 1, 1),
        ),
      ]);

  @override
  Stream<bool> watchPostLike(
          {required String postId, required String? userId}) =>
      Stream.value(false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
