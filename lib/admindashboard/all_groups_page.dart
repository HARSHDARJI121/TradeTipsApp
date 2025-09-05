import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/admindashboard/admin_private_chat_page.dart';
import '../messages/messages_page.dart';

class AllGroupsPage extends StatelessWidget {
  const AllGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = [
      {
        'name': 'StockTrade',
        'subtitle': 'General group for all users',
        'icon': Icons.group,
        'color': Colors.blue,
        'gradient': [Color(0xFF2193b0), Color(0xFF6dd5ed)],
      },
      {
        'name': 'StockTrade Premium',
        'subtitle': 'Exclusive for premium members',
        'icon': Icons.workspace_premium,
        'color': Colors.deepPurple,
        'gradient': [Color(0xFF8e2de2), Color(0xFF4a00e0)],
      },
      {
        'name': 'StockTrade Future',
        'subtitle': 'Futures & advanced trading',
        'icon': Icons.trending_up,
        'color': Colors.green,
        'gradient': [Color(0xFF11998e), Color(0xFF38ef7d)],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'All Groups',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        titleTextStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: SingleChildScrollView(
          // <-- Make the whole page scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Groups Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF283E51),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1.2),
              const SizedBox(height: 12),

              // 🔹 Group Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groups.length,
                separatorBuilder: (context, i) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GroupChatPage(
                              groupName: group['name'] as String,
                              groupIcon: group['icon'] as IconData,
                              groupColor: group['color'] as Color,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: List<Color>.from(
                                      group['gradient'] as List,
                                    ),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (group['color'] as Color)
                                          .withOpacity(0.18),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    group['icon'] as IconData,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 22),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group['name'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFF283E51),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      group['subtitle'] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF6C7A89),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFFB0B0B0),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1.2),
              const SizedBox(height: 12),
              const Text(
                'User Chats (Direct to Admin)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF283E51),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              // 🔹 All users who messaged admin (from admin_chats collection)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('admin_chats')
                    .where('lastMessageTimestamp', isNull: false)
                    .orderBy('lastMessageTimestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    print('Error loading admin chats: ${snapshot.error}');
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Failed to load user chats'),
                    );
                  }

                  final chats = snapshot.data?.docs ?? [];
                  if (chats.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('No user chats yet'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = chats[index];
                      final data = doc.data() as Map<String, dynamic>? ?? {};
                      final userId = doc.id; // Using per-user doc model
                      final userName = data['userName'] ?? 'User';
                      final userEmail = data['userEmail'] ?? '';
                      final lastMessage = data['lastMessage'] ?? '';
                      final lastTime =
                          data['lastMessageTimestamp'] as Timestamp?;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.withOpacity(
                              0.15,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.deepPurple,
                            ),
                          ),
                          title: Text(
                            userName.isNotEmpty
                                ? userName
                                : (userEmail.isNotEmpty
                                      ? userEmail.split('@').first
                                      : userId),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            lastMessage.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (lastTime != null)
                                Text(
                                  _formatRelativeTime(lastTime.toDate()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AdminDirectChatPage(
                                  userId: userId,
                                  userName: userName,
                                  userEmail: userEmail,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatRelativeTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}
