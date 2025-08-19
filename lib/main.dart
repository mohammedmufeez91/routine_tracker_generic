import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/timeslot_provider.dart';
import 'providers/template_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/home_screen.dart';
import 'screens/manage_timeslots_screen.dart';
import 'screens/create_template_screen.dart';
import 'screens/daily_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/create_goal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoutineApp());
}

class RoutineApp extends StatelessWidget {
  const RoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0B6B3A);
    const gold = Color(0xFFD4AF37);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeSlotProvider()..init()),
        ChangeNotifierProvider(create: (_) => TemplateProvider()..init()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Routine Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: green).copyWith(
            primary: green,
            secondary: gold,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: green,
            foregroundColor: Colors.white,
          ),
          cardTheme: const CardTheme(
            elevation: 1,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/timeslots': (_) => const ManageTimeSlotsScreen(),
          '/create-template': (_) => const CreateTemplateScreen(),
          '/daily': (_) => const DailyScreen(),
          '/stats': (_) => const StatsScreen(),
          '/goalsetting': (_) => const CreateGoalScreen(),
        },
      ),
    );
  }
}
