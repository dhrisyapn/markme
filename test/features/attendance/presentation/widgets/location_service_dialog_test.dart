import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/theme/app_theme.dart';
import 'package:markme/features/attendance/presentation/widgets/location_service_dialog.dart';

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

  testWidgets('LocationServiceDialog renders title, message, and single settings button', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool settingsOpened = false;

    await tester.pumpWidget(
      buildTestableWidget(
        LocationServiceDialog(
          onOpenSettings: () {
            settingsOpened = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify dialog title and explanation text
    expect(find.text('Enable Location'), findsOneWidget);
    expect(
      find.text(
        'Location service is disabled on your device. Please turn on location in your device settings to use MarkMe and mark your attendance.',
      ),
      findsOneWidget,
    );

    // Verify icons
    expect(find.byIcon(Icons.location_off_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);

    // Verify only ONE button exists (Open Location Settings)
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('Open Location Settings'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
    expect(find.text('Close'), findsNothing);

    // Verify PopScope cannot pop (non-dismissible)
    final popScopeFinder = find.byType(PopScope);
    expect(popScopeFinder, findsOneWidget);
    final popScope = tester.widget<PopScope>(popScopeFinder);
    expect(popScope.canPop, isFalse);

    // Tap the settings button and verify callback
    await tester.tap(find.text('Open Location Settings'));
    await tester.pump();
    expect(settingsOpened, isTrue);
  });
}

