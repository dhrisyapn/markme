import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/injection.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/bloc/admin_records/admin_records_bloc.dart';
import 'features/admin/presentation/bloc/qr_session/qr_session_bloc.dart';
import 'features/attendance/presentation/bloc/attendance/attendance_bloc.dart';
import 'features/attendance/presentation/bloc/history/history_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

/// Root Application Widget configured with Theme, Dependency Injection, BLoC providers, Router, and ScreenUtil.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final dynamic _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AppStarted());
    _router = createRouter(_authBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<QrSessionBloc>(create: (_) => sl<QrSessionBloc>()),
        BlocProvider<AdminRecordsBloc>(create: (_) => sl<AdminRecordsBloc>()),
        BlocProvider<AttendanceBloc>(create: (_) => sl<AttendanceBloc>()),
        BlocProvider<HistoryBloc>(create: (_) => sl<HistoryBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'MarkMe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
