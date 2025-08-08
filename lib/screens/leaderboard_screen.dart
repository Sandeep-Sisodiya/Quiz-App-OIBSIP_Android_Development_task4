import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LeaderboardScreen extends StatefulWidget {
  final String quizId;
  const LeaderboardScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<String> getUserName(String userId) async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] ?? 'User';
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2634),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/available'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Leaderboard',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Lottie.asset(
            'assets/lottie/leaderboard_trophy.json',
            height: 160,
            repeat: false,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attempts')
                  .where('quizId', isEqualTo: widget.quizId)
                  .orderBy('score', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No scores yet!',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final userId = data['userId'] ?? '';
                    final userScore = data['score'] ?? 0;

                    final start = (index * 0.1).clamp(0.0, 1.0);
                    final end = (start + 0.5).clamp(0.0, 1.0);

                    return FutureBuilder<String>(
                      future: getUserName(userId),
                      builder: (context, userSnapshot) {
                        final userName = userSnapshot.data ?? 'User';

                        return AnimatedBuilder(
                          animation: _listController,
                          builder: (context, child) {
                            final anim = CurvedAnimation(
                              parent: _listController,
                              curve: Interval(start, end, curve: Curves.easeOut),
                            ).value;
                            return Opacity(
                              opacity: anim,
                              child: Transform.translate(
                                offset: Offset((1 - anim) * -50, 0),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  index == 0
                                      ? const Color(0xFFFFD700)
                                      : Colors.teal.shade400,
                                  index == 0
                                      ? const Color(0xFFFFC107)
                                      : Colors.blueGrey.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: index == 0
                                          ? Colors.deepOrange.shade800
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$userScore pts',
                                  style: GoogleFonts.poppins(
                                    color: Colors.tealAccent.shade100,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
