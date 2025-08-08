import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';
import '../widgets/custom_drawer.dart';
import 'available_quizzes.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Cloud Quiz',
          style: GoogleFonts.orbitron(
            textStyle: TextStyle(
              fontSize: size.width * 0.08,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xffa42442)),
        ),
      ),
      drawer: buildAppDrawer(context, user, _confirmLogout),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 10),
                // Lottie Animation
                Lottie.asset(
                  'assets/lottie/playQuiz.json',
                  height: size.height * 0.25,
                  repeat: true,
                ),
                const SizedBox(height: 20),
                // Welcome Text
                Text(
                  'Welcome👋 ${user?.displayName ?? 'User'}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    textStyle: TextStyle(
                      fontSize: size.width * 0.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Divider
                Container(
                  width: double.infinity,
                  height: 4.0,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/icons/logo3.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  text: 'Create New Quiz',
                  icon: Icons.add_circle_outline,
                  onTap: () => Navigator.pushNamed(context, '/createQuiz'),
                ),
                const SizedBox(height: 20),
                // Divider
                Container(
                  width: double.infinity,
                  height: 4.0,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                const SizedBox(height: 25),
                Image.asset(
                  'assets/icons/logo4.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                _buildMainButton(
                  text: 'Available Quizzes',
                  icon: Icons.list_alt_outlined,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AvailableQuizzesScreen())),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffc21c55), Color(0xffe8bd38)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
