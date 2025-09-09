import 'package:budget_buddy/services/auth_service.dart';
import 'package:budget_buddy/services/database_service.dart';
import 'package:budget_buddy/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/session_manager.dart';
import 'package:budget_buddy/screens/splash_screen.dart' show SplashScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SessionManager>(create: (_) => SessionManager()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: AppColors.secondaryColor,
          ),
          scaffoldBackgroundColor: AppColors.backgroundColor,
          fontFamily: 'Roboto',
        ),
        home:  SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}