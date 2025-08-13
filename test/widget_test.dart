import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:active_quest/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Квест Приключение'), findsOneWidget);
  });

  testWidgets('Quest completion updates progress', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Находим первый квест и нажимаем на него
    final firstQuest = find.text('Пройти 10,000 шагов');
    expect(firstQuest, findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
    await tester.pump();
    
    // Проверяем, что прогресс обновился
    expect(find.text('33.3% пути пройдено'), findsOneWidget);
  });
}