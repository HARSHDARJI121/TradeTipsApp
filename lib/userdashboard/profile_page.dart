import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditingName = false;
  bool isEditingAbout = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  String? email;
  String? phoneNumber;
  String? uid;

  bool isLoading = true;

  // WhatsApp-style status options
  final List<String> aboutOptions = [
    "Available",
    "Busy",
    "At the movies",
    "Battery about to die",
    "Can't talk, WhatsApp only",
    "In a meeting",
    "At work",
    "Urgent calls only",
    "Hey there! I am using WhatsApp.",
    "Sleeping",
    "In class",
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      email = user.email;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        nameController.text = data?['name'] ?? 'John Doe';
        aboutController.text = data?['about'] ?? 'Available';
        phoneNumber = data?['phone']; // Can be null
      } else {
        // Initialize default values if user doc doesn't exist
        nameController.text = 'John Doe';
        aboutController.text = 'Available';
        phoneNumber = null;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveUserData() async {
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text,
        'about': aboutController.text,
        'phone': phoneNumber, // Keep existing phone if already there
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 218, 218, 219),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile image or logo
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile.jpg'), // replace with actual image logic if needed
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 20),

          // Name section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(isEditingName ? Icons.check : Icons.edit),
                onPressed: () async {
                  if (isEditingName) await saveUserData();
                  setState(() {
                    isEditingName = !isEditingName;
                  });
                },
              ),
            ],
          ),
          isEditingName
              ? TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Enter your name"),
                )
              : Text(nameController.text, style: const TextStyle(fontSize: 18)),

          const Divider(height: 30),

          // Email (read-only)
          const Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(email ?? 'Not available', style: const TextStyle(fontSize: 18)),

          const Divider(height: 30),

          // Phone (optional, read-only)
          if (phoneNumber != null) ...[
            const Text("Phone", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(phoneNumber!, style: const TextStyle(fontSize: 18)),
            const Divider(height: 30),
          ],

          // About section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("About", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(isEditingAbout ? Icons.check : Icons.edit),
                onPressed: () async {
                  if (isEditingAbout) await saveUserData();
                  setState(() {
                    isEditingAbout = !isEditingAbout;
                  });
                },
              ),
            ],
          ),
          isEditingAbout
              ? Column(
                  children: [
                    TextField(
                      controller: aboutController,
                      decoration: const InputDecoration(hintText: "Enter your status"),
                    ),
                    const SizedBox(height: 10),
                    const Text("Common Abouts:"),
                    Wrap(
                      spacing: 8.0,
                      children: aboutOptions.map((option) {
                        return ActionChip(
                          label: Text(option),
                          onPressed: () {
                            setState(() {
                              aboutController.text = option;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                )
              : Text(aboutController.text, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
