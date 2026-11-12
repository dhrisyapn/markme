import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/theme/app_theme.dart';
import 'package:markme/features/admin/presentation/widgets/qr_duration_picker_sheet.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: child,
          ),
        );
      },
    );
  }

  testWidgets('QrDurationPickerSheet renders presets and custom input', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int? selectedDuration;

    await tester.pumpWidget(
      buildTestableWidget(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                selectedDuration = await showQrDurationPickerSheet(context, initialDurationMinutes: 2);
              },
              child: const Text('Open Sheet'),
            );
          },
        ),
      ),
    );

    // Tap to open sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify title and header elements
    expect(find.text('Set QR Expiration'), findsOneWidget);
    expect(find.text('QUICK PRESETS'), findsOneWidget);
    expect(find.text('2 min (Default)'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('Generate QR Code (2 mins)'), findsOneWidget);

    // Tap 5 min preset
    await tester.tap(find.text('5 min'));
    await tester.pumpAndSettle();

    // Verify button updated
    expect(find.text('Generate QR Code (5 mins)'), findsOneWidget);

    // Tap generate
    await tester.tap(find.text('Generate QR Code (5 mins)'));
    await tester.pumpAndSettle();

    // Verify duration returned
    expect(selectedDuration, 5);
  });

  testWidgets('QrDurationPickerSheet stepper increments and decrements minutes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int? selectedDuration;

    await tester.pumpWidget(
      buildTestableWidget(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                selectedDuration = await showQrDurationPickerSheet(context, initialDurationMinutes: 1);
              },
              child: const Text('Open Sheet'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Generate QR Code (1 min)'), findsOneWidget);

    // Tap increment '+'
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Generate QR Code (2 mins)'), findsOneWidget);

    // Tap increment '+' again
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Generate QR Code (3 mins)'), findsOneWidget);

    // Tap confirm
    await tester.tap(find.text('Generate QR Code (3 mins)'));
    await tester.pumpAndSettle();

    expect(selectedDuration, 3);
  });
}

