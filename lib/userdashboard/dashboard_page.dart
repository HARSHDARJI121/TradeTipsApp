import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/admindashboard/news_page.dart';
import 'package:flutter_application_1/authication/helpers/auth_service.dart';
import 'package:flutter_application_1/authication/sign_in.dart';
import 'package:flutter_application_1/messages/messages_page.dart';
import 'package:flutter_application_1/plan/user_plan_page.dart';

import 'image_carousel.dart';
import 'about_section.dart';
import 'portfolio_management_section.dart';
import 'premium_plans_section.dart';
import 'contact_section.dart';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe8f5f0),

      // ✅ Drawer Sidebar
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1f4037), Color(0xFF99f2c8)],
                ),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Welcome, User!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text("News"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewsPage(isAdmin: false),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Plan"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => UserPlanPage()));
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: () async {
                    final _authService = AuthService();
                    await _authService.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SignInPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // ✅ App Bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1f4037), Color(0xFF99f2c8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.menu, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      String name = "User";
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        name = data?['name'] ?? "User";
                      }
                      return Text(
                        "Hello, $name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MessagesPage(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.message_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ✅ Main Body
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ImageCarousel(),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.article, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        'Latest News',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Stock Trade',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('news')
                        .orderBy('timestamp', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading news.'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final newsDocs = snapshot.data!.docs;
                      if (newsDocs.isEmpty) {
                        return const Center(child: Text('No news yet.'));
                      }

                      return SizedBox(
                        height: 180,
                        child: PageView.builder(
                          itemCount: newsDocs.length,
                          controller: PageController(viewportFraction: 0.95),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final news = newsDocs[index];
                            DateTime? dateTime;
                            if (news['timestamp'] != null) {
                              final ts = news['timestamp'];
                              if (ts is Timestamp) {
                                dateTime = ts.toDate();
                              } else if (ts is DateTime) {
                                dateTime = ts;
                              }
                            }
                            String dateStr = dateTime != null
                                ? '${dateTime.day.toString().padLeft(2, '0')} '
                                      '${_monthName(dateTime.month)} '
                                      '${dateTime.year}'
                                : '';

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade700,
                                    const Color.fromARGB(255, 125, 221, 83),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      color: Color.fromARGB(179, 242, 238, 238),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Title with dynamic size
                                  AutoSizeText(
                                    news['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    minFontSize: 14,
                                    maxFontSize: 22,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Content with dynamic size
                                  Expanded(
                                    child: AutoSizeText(
                                      news['content'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      maxLines: 6,
                                      minFontSize: 10,
                                      maxFontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );

                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NewsPage(isAdmin: false),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View All News',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            const AboutSection(),
            const PortfolioManagementSection(),
            const PremiumPlansSection(),
            const ContactSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

String _monthName(int month) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month];
}
