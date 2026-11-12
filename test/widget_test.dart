import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('Org Fair app starts with organizations', (tester) async {
    await openApp(tester);
    expect(find.text('Computer Science Circle'), findsOneWidget);
  });
}
