import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _search = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs.where((doc) {
                  final name = (doc['name'] ?? '').toString().toLowerCase();
                  final email = (doc['email'] ?? '').toString().toLowerCase();
                  return name.contains(_search) || email.contains(_search);
                }).toList();
                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (context, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final data = user.data() as Map<String, dynamic>;
                    final provider = (data['provider'] ?? '').toString();
                    IconData providerIcon;
                    Color providerColor;
                    if (provider.contains('google')) {
                      providerIcon = Icons.account_circle;
                      providerColor = Colors.redAccent;
                    } else if (provider.contains('password') || provider.contains('email')) {
                      providerIcon = Icons.email;
                      providerColor = Colors.blueAccent;
                    } else {
                      providerIcon = Icons.person;
                      providerColor = Colors.grey;
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: providerColor.withOpacity(0.15),
                        child: Icon(providerIcon, color: providerColor),
                      ),
                      title: Text(data['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['email'] ?? 'No Email'),
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