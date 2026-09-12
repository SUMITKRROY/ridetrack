import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/di/injection_container.dart' as di;
import 'features/trip/presentation/bloc/trip_bloc.dart';
import 'features/trip/presentation/bloc/location_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const KSKTRiderApp());
}

class KSKTRiderApp extends StatelessWidget {
  const KSKTRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<TripBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<LocationBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'KSKT Rider',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
