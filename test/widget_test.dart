import 'package:flutter_test/flutter_test.dart';
import 'package:lexoria/main.dart';

void main() {
  testWidgets('LEXORIA home screen opens with solo campaign entry', (tester) async {
    await tester.pumpWidget(const LexoriaApp());

    expect(find.text('LEXORIA'), findsOneWidget);
    expect(find.text('Mode Solo'), findsOneWidget);
    expect(find.text('LANCER LE DÉFI'), findsOneWidget);
  });
}
