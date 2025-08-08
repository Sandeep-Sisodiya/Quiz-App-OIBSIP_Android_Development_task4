import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

void showCustomLogoutDialog(BuildContext context, VoidCallback onLogout) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Colors.white38,
            width: 3,
          ),
        ),
        backgroundColor: Colors.black87,
        title: Text(
          'Logout',
          style: GoogleFonts.orbitron(
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.white70,
              fontWeight: FontWeight.w900,
            ),
          )
          ,
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.deepOrange)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    },
  );
}

Drawer buildAppDrawer(
    BuildContext context,
    User? user,
    VoidCallback onLogout,
    ) {
  return Drawer(
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2027),
            Color(0xFF2C5364),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xffa42442),
                  Color(0xff7e1f36),
                  Color(0xFF2C5364),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Text(
                    (user?.displayName?.isNotEmpty ?? false)
                        ? user!.displayName![0].toUpperCase()
                        : 'G',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? 'Guest',
                  style: GoogleFonts.orbitron(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerTile(
            context,
            icon: Icons.home,
            label: 'Home',
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          _buildDrawerTile(
            context,
            icon: Icons.person,
            label: 'My Profile',
            onTap: () => Navigator.pushNamed(context, '/myProfile'),
          ),
          _buildDrawerTile(
            context,
            icon: Icons.add,
            label: 'Create Quiz',
            onTap: () => Navigator.pushNamed(context, '/createQuiz'),
          ),
          _buildDrawerTile(
            context,
            icon: Icons.list_alt,
            label: 'Available Quizzes',
            onTap: () => Navigator.pushNamed(context, '/available'),
          ),
          _buildDrawerTile(
            context,
            icon: Icons.history,
            label: 'Quiz History',
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
          const Divider(color: Colors.white54),
          _buildDrawerTile(
            context,
            icon: Icons.logout,
            label: 'Logout',
            onTap: () => showCustomLogoutDialog(context, onLogout),
          ),

        ],
      ),
    ),
  );
}

Widget _buildDrawerTile(
    BuildContext context, {
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );
}
