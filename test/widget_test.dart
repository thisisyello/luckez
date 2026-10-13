import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/pages/lotto_draw_page.dart';
import 'package:luckez/widgets/lotto_ball.dart';

void main() {
  testWidgets('Home generates valid numbers and passes them to save callback',
      (tester) async {
    List<int>? savedNumbers;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LottoDrawPage(
          savedNumbersCount: 2,
          onSaveNumbers: (numbers) => savedNumbers = List.of(numbers),
        ),
      ),
    ));

    List<int> displayedNumbers() => tester
        .widgetList<LottoBall>(find.byType(LottoBall))
        .map((ball) => ball.number)
        .toList();

    void expectValidNumbers(List<int> numbers) {
      expect(numbers, hasLength(6));
      expect(numbers.toSet(), hasLength(6));
      expect(numbers.every((number) => number >= 1 && number <= 45), isTrue);
      expect(numbers, List<int>.of(numbers)..sort());
    }

    expectValidNumbers(displayedNumbers());
    expect(find.text('저장한 번호 2개'), findsOneWidget);
    await tester.tap(find.text('다시 뽑기'));
    await tester.pump();
    final numbers = displayedNumbers();
    expectValidNumbers(numbers);
    await tester.tap(find.text('저장하기'));
    expect(savedNumbers, numbers);
  });
}
