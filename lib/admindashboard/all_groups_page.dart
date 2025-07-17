import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../messages/messages_page.dart';
import '../admindashboard/admin_private_chat_page.dart';

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
            // Group cards
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
            const SizedBox(height: 32),
            const Text(
              'User Chats',
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
            // User chat cards
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc('admin_chat')
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  // Get unique users (exclude admin messages)
                  final Map<String, Map<String, String>> users = {};
                  for (final doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final senderId = data['senderId'] ?? '';
                    final senderName = data['senderName'] ?? 'User';
                    final senderEmail = data['senderEmail'] ?? '';
                    final recipientId = data['recipientId'] ?? '';
                    // Only include users (not admin) who sent to admin
                    if (recipientId == 'admin' && senderId != 'admin') {
                      users[senderId] = {
                        'name': senderName,
                        'email': senderEmail,
                      };
                    }
                  }
                  if (users.isEmpty) {
                    return const Center(child: Text('No user messages yet.'));
                  }
                  final userList = users.entries.toList();
                  return ListView.separated(
                    itemCount: userList.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final userId = userList[index].key;
                      final user = userList[index].value;
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFFE0B2),
                            child: Icon(Icons.person, color: Colors.orange),
                          ),
                          title: Text(
                            user['name'] ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(user['email'] ?? ''),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.orange,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AdminPrivateChatPage(
                                  userId: userId,
                                  userName: user['name'] ?? 'User',
                                  userEmail: user['email'] ?? '',
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
            ),
          ],
        ),
      ),
    );
  }
}
