import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markme/core/widgets/shimmer_loading.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('AdminMetricsRowShimmer renders two shimmer metric placeholders', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AdminMetricsRowShimmer()));
    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.byType(ShimmerBox), findsNWidgets(6));
  });

  testWidgets('AdminRecordsListShimmer renders requested number of shimmer items', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AdminRecordsListShimmer(itemCount: 3)));
    expect(find.byType(AdminRecordCardShimmer), findsNWidgets(3));
    expect(find.byType(Shimmer), findsOneWidget);
  });

  testWidgets('HistoryPageShimmer renders summary and history record shimmer placeholders', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const HistoryPageShimmer(itemCount: 2)));
    expect(find.byType(HistorySummaryCardShimmer), findsOneWidget);
    expect(find.byType(HistoryRecordCardShimmer), findsNWidgets(2));
    expect(find.byType(Shimmer), findsOneWidget);
  });

  testWidgets('TodayAttendanceCardShimmer renders today status skeleton', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const TodayAttendanceCardShimmer()));
    expect(find.byType(TodayAttendanceCardShimmer), findsOneWidget);
    expect(find.byType(Shimmer), findsOneWidget);
  });

  testWidgets('QrSessionGeneratingShimmer renders QR session skeleton', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const QrSessionGeneratingShimmer()));
    expect(find.byType(QrSessionGeneratingShimmer), findsOneWidget);
    expect(find.byType(Shimmer), findsOneWidget);
  });
}

