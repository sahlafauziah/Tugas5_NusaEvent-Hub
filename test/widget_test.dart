import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_sesi_5/main.dart';

void main() {
  testWidgets('NusaEvent Hub menampilkan tiga menu navigasi bawah', (tester) async {
    await tester.pumpWidget(const NusaEventHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Seminar'), findsOneWidget);
    expect(find.text('Galeri'), findsOneWidget);
    expect(find.text('Tiket'), findsOneWidget);
  });
}
