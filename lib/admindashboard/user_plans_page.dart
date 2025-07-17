import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserPlansPage extends StatelessWidget {
  final String userId;
  final String userName;

  const UserPlansPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  String formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(date.toDate());
    }
    if (date is DateTime) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
    if (date is String) {
      try {
        return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
      } catch (_) {
        return date;
      }
    }
    return 'N/A';
  }

  String getPlanCharge(String planName) {
    if (planName.toLowerCase().contains('premium')) {
      return '1999'; // Premium Plan Charge
    } else if (planName.toLowerCase().contains('future')) {
      return '2999'; // Future Plan Charge
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text("$userName's Plans"),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('plans')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No plans found.'));
          }

          final plans = snapshot.data!.docs;

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final planData = plans[index].data() as Map<String, dynamic>;
              final planName = planData['planName'] ?? 'Unknown Plan';
              final planCharge = getPlanCharge(planName);
              final startTimestamp = planData['startDate'] as Timestamp?;
              final startDate = startTimestamp?.toDate();

              int durationDays = 0;
              if (planName.toLowerCase().contains('future')) {
                durationDays = 80;
              } else if (planName.toLowerCase().contains('premium')) {
                durationDays = 30;
              }

              DateTime? endDate;
              if (startDate != null && durationDays > 0) {
                endDate = startDate.add(Duration(days: durationDays));
              }

              final isExpired = endDate != null && endDate.isBefore(now);

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: Icon(
                    Icons.workspace_premium,
                    color: isExpired ? Colors.red : Colors.green,
                  ),
                  title: Text(planName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Plan Charges: ₹$planCharge'),
                      Text('Start Date: ${formatDate(startDate)}'),
                      Text('End Date: ${formatDate(endDate)}'),
                      Text(
                        'Status: ${isExpired ? 'Expired' : 'Active'}',
                        style: TextStyle(
                          color: isExpired ? Colors.red : Colors.green,
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
      ),
    );
  }
}
