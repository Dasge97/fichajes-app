import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/clocking/data/clocking_repository.dart';
import 'features/clocking/presentation/clocking_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final apiClient = ApiClient(config);
  final authRepository = AuthRepository(apiClient);
  final clockingRepository = ClockingRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: config),
        Provider.value(value: apiClient),
        Provider.value(value: authRepository),
        ChangeNotifierProvider(
          create: (_) => AuthController(authRepository)..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClockingController(clockingRepository),
        ),
      ],
      child: const FichajesApp(),
    ),
  );
}
