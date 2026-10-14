import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/models/community_comment.dart';
import 'package:luckez/models/community_post.dart';
import 'package:luckez/pages/community_post_detail_page.dart';
import 'package:luckez/repositories/community_repository.dart';

void main() {
  late _TestRepository repository;
  final comments = List.generate(
      20,
      (index) => CommunityComment(
            id: '$index',
            content: 'Comment $index',
            authorId: 'other',
            authorName: 'Author',
            createdAt: DateTime(2026, 1, 1),
          ));

  Widget page({String userId = 'user', String postId = 'post'}) => MaterialApp(
        home: CommunityPostDetailPage(
          post: CommunityPost(
            id: postId,
            title: 'Title',
            content: List.filled(8, 'Post content').join('\n'),
            authorId: 'other',
            authorName: 'Author',
            commentCount: 20,
            likeCount: 0,
            createdAt: DateTime(2026, 1, 1),
          ),
          currentUserId: userId,
          currentUserName: 'User',
          isAdmin: false,
          onLoginRequired: () {},
          communityRepository: repository,
        ),
      );

  setUp(() => repository = _TestRepository());
  tearDown(() async {
    await repository.comments.close();
    await repository.likes.close();
  });

  Future<ScrollPosition> prepare(WidgetTester tester) async {
    await tester.pumpWidget(page());
    repository.comments.add(comments);
    repository.likes.add(false);
    await tester.pumpAndSettle();
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    position.jumpTo(200);
    await tester.pumpAndSettle();
    return position;
  }

  testWidgets('Like rebuild keeps comment subscription and scroll offset',
      (tester) async {
    final position = await prepare(tester);
    await tester.ensureVisible(find.text('좋아요 0'));
    await tester.pumpAndSettle();
    final offset = position.pixels;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('좋아요 0'));
    await tester.pumpAndSettle();
    expect(repository.likeWrites, 1);
    expect(repository.commentWatches, 1);
    expect(repository.likeWatches, 1);
    expect(find.text('좋아요 1'), findsOneWidget);
    expect(position.pixels, closeTo(offset, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Comment submission keeps input and scroll while pending and after completion',
      (tester) async {
    final position = await prepare(tester);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'New comment');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final offset = position.pixels;
    expect(offset, greaterThan(0));
    await tester.tap(find.text('등록'));
    await tester.pump();
    expect(repository.commentWrites, 1);
    expect(repository.commentWatches, 1);
    expect(repository.likeWatches, 1);
    expect(find.byType(TextField), findsOneWidget);
    expect(position.pixels, closeTo(offset, 0.01));
    repository.comments.add([
      ...comments,
      CommunityComment(
        id: 'new',
        content: 'New comment',
        authorId: 'user',
        authorName: 'User',
        createdAt: DateTime(2026, 1, 2),
      )
    ]);
    repository.pendingComment.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(repository.commentWatches, 1);
    expect(repository.likeWatches, 1);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
    expect(position.pixels, closeTo(offset, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Streams rebind only when user or post changes and cancel on disposal',
      (tester) async {
    await prepare(tester);
    await tester.pumpWidget(page());
    expect(repository.commentWatches, 1);
    expect(repository.likeWatches, 1);
    await tester.pumpWidget(page(userId: 'another'));
    expect(repository.commentWatches, 1);
    expect(repository.likeWatches, 2);
    await tester.pumpWidget(page(userId: 'another', postId: 'another-post'));
    expect(repository.commentWatches, 2);
    expect(repository.likeWatches, 3);
    await tester.pumpWidget(const SizedBox());
    expect(repository.comments.hasListener, isFalse);
    expect(repository.likes.hasListener, isFalse);
    expect(tester.takeException(), isNull);
  });
}

class _TestRepository implements CommunityRepository {
  final comments = StreamController<List<CommunityComment>>.broadcast();
  final likes = StreamController<bool>.broadcast();
  Completer<void>? _pendingComment;
  Completer<void> get pendingComment => _pendingComment ??= Completer<void>();
  int commentWatches = 0;
  int likeWatches = 0;
  int commentWrites = 0;
  int likeWrites = 0;

  @override
  Stream<List<CommunityComment>> watchComments(String postId) {
    commentWatches++;
    return comments.stream.map((value) => value);
  }

  @override
  Stream<bool> watchPostLike(
      {required String postId, required String? userId}) {
    likeWatches++;
    return likes.stream.map((value) => value);
  }

  @override
  Future<void> togglePostLike(
      {required String postId,
      required String userId,
      required String userName}) async {
    likeWrites++;
    likes.add(true);
  }

  @override
  Future<void> createComment(
      {required String postId,
      required String content,
      required String authorId,
      required String authorName}) {
    commentWrites++;
    return pendingComment.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
