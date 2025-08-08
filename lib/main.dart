import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz_master/screens/available_quizzes.dart';
import 'package:quiz_master/screens/edit_quiz_screen.dart';
import 'package:quiz_master/screens/my_profile_screen.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_quiz_screen.dart';
import 'screens/attempt_quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/quiz_history_screen.dart';
import 'screens/leaderboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/createQuiz': (context) => CreateQuizScreen(),
        '/attemptQuiz': (context) => AttemptQuizScreen(),
        '/result': (context) => ResultScreen(),
        '/history': (context) => QuizHistoryScreen(),
        '/leaderboard': (ctx) {
          final quizId = ModalRoute.of(ctx)!.settings.arguments as String;
          return LeaderboardScreen(quizId: quizId);
        },
        '/myProfile': (ctx) => MyProfileScreen(),
        '/editQuiz': (ctx) => EditQuizScreen(),
        '/available': (ctx) => AvailableQuizzesScreen(),

      },
    );
  }
}
