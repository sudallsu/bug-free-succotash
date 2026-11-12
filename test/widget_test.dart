import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fanhub_archive/main.dart';
import 'package:fanhub_archive/services/app_repository.dart';

void main() {
  testWidgets('앱이 정상적으로 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(FanHubApp(repository: LocalRepository()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
