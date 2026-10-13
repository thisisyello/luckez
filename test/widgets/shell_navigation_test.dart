import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/shell_app_bar.dart';
import 'package:luckez/widgets/shell_bottom_navigation_bar.dart';

void main() {
  for (final inset in [0.0, 24.0, 34.0]) {
    testWidgets('Floating action clears navigation with safe inset $inset',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.viewPadding = FakeViewPadding(bottom: inset);
      tester.view.padding = FakeViewPadding(bottom: inset);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewPadding);
      addTearDown(tester.view.resetPadding);
      double? extent;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          extent = shellBottomBarExtent(context);
          return Scaffold(
            extendBody: true,
            body: Builder(builder: (context) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: 20,
                    bottom: extent! + shellFloatingActionGap,
                    child: FloatingActionButton.extended(
                      onPressed: () {},
                      label: const Text('글쓰기'),
                    ),
                  ),
                ],
              );
            }),
            bottomNavigationBar: ShellBottomNavigationBar(
              selectedIndex: 4,
              onDestinationSelected: (_) {},
            ),
          );
        }),
      ));
      final bar = tester.getRect(find.byType(ShellBottomNavigationBar));
      final button = tester.getRect(find.byType(FloatingActionButton));
      expect(bar.top - button.bottom, closeTo(shellFloatingActionGap, 0.01));
      expect(extent, inset == 0 ? 76 : 68 + inset);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('App bar uses profile fallback and forwards button presses',
      (tester) async {
    var accountPresses = 0;
    var notificationPresses = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: ShellAppBar(
          photoUrl: null,
          unreadCount: 0,
          onAccountPressed: () => accountPresses++,
          onNotificationsPressed: () => notificationPresses++,
        ),
      ),
    ));
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    expect(find.text('0'), findsNothing);
    await tester.tap(find.byTooltip('계정'));
    await tester.tap(find.byTooltip('알림'));
    expect(accountPresses, 1);
    expect(notificationPresses, 1);
    final bar = tester.widget<ShellAppBar>(find.byType(ShellAppBar));
    expect(bar.preferredSize.height, kToolbarHeight + 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unread badge updates and caps its label at 99+', (tester) async {
    Future<void> pump(int count) => tester.pumpWidget(MaterialApp(
          home: Scaffold(
            appBar: ShellAppBar(
              photoUrl: ' ',
              unreadCount: count,
              onAccountPressed: () {},
              onNotificationsPressed: () {},
            ),
          ),
        ));
    await pump(5);
    expect(find.text('5'), findsOneWidget);
    await pump(100);
    expect(find.text('99+'), findsOneWidget);
    await pump(0);
    expect(find.text('99+'), findsNothing);
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
  });

  for (final width in [390.0, 1024.0]) {
    testWidgets('Navigation preserves tab order and selection at width $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewPadding);
      var selected = 0;
      await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(builder: (context, setState) {
          return Scaffold(
            extendBody: selected != 2,
            body: const SizedBox.expand(key: ValueKey('shell-body')),
            appBar: ShellAppBar(
              photoUrl: null,
              unreadCount: 1,
              onAccountPressed: () {},
              onNotificationsPressed: () {},
            ),
            bottomNavigationBar: ShellBottomNavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (index) {
                setState(() => selected = index);
              },
            ),
          );
        }),
      ));
      final destinations = tester.widgetList<NavigationDestination>(
        find.byType(NavigationDestination),
      );
      expect(destinations.map((destination) => destination.label),
          ['홈', '통계', '구매', '내 번호', '커뮤니티']);
      for (var index = 0; index < destinations.length; index++) {
        await tester.tap(find.text(destinations.elementAt(index).label));
        await tester.pumpAndSettle();
        expect(selected, index);
        expect(
            tester
                .widget<NavigationBar>(find.byType(NavigationBar))
                .selectedIndex,
            index);
        final bodyBottom =
            tester.getRect(find.byKey(const ValueKey('shell-body'))).bottom;
        final navigationTop =
            tester.getRect(find.byType(ShellBottomNavigationBar)).top;
        if (index == 2) {
          expect(bodyBottom, lessThanOrEqualTo(navigationTop));
        } else {
          expect(bodyBottom, greaterThan(navigationTop));
        }
        expect(tester.takeException(), isNull);
      }
    });
  }
}
