import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/players_provider.dart';
import 'providers/workout_plans_provider.dart';
import 'providers/exercises_provider.dart';
import 'providers/subscriptions_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlayersProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutPlansProvider()),
        ChangeNotifierProvider(create: (_) => ExercisesProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionsProvider()),
      ],
      child: MaterialApp(
        title: 'مدرب مجدل',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('ar'), // Arabic
        ],
        locale: const Locale('ar'), // Force Arabic
        home: const SplashScreen(),
      ),
    );
  }
}
