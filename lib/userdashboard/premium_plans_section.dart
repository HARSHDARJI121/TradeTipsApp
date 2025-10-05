import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PremiumPlansSection extends StatefulWidget {
  const PremiumPlansSection({super.key});

  @override
  _PremiumPlansSectionState createState() => _PremiumPlansSectionState();
}

class _PremiumPlansSectionState extends State<PremiumPlansSection>
    with WidgetsBindingObserver {
  late Razorpay _razorpay;
  String _lastPlanType = "Free Plan";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _razorpay.clear(); // Clean up
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 🛠️ Handle app resume after payment if needed
    }
  }

  void openCheckout({required String amount, required String planType}) {
    var options = {
      'key': 'rzp_test_RPmVzMiZjk5mmt', // ✅ Replace with your Razorpay Key ID
      'amount': int.parse(amount) * 100, // Razorpay works with paise
      'name': 'StockTrade',
      'description': planType,
      'prefill': {
        'contact': '7400356323',
        'email': 'darrjiharsh2005@gmail.com',
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
      setState(() {
        _lastPlanType = planType;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'User',
        'userEmail': user.email,
        'planName': _lastPlanType,
        'type': _lastPlanType,
        // Correct mapping:
        'groupName': _lastPlanType == "Standard Plan"
            ? "premium" // Standard Plan → StockTrade Premium group
            : _lastPlanType == "Premium Plan"
            ? "future" // Premium Plan → StockTrade Future group
            : "free",
        'paymentId': response.paymentId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✅ Payment Successful\nPayment ID: ${response.paymentId}\nJoin request sent to admin!",
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Payment Failed\n${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Wallet Selected: ${response.walletName}"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width > 900
        ? 900
        : double.infinity;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Premium Plans",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1f4037),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PlanCard(
                        icon: Icons.star_border,
                        title: "Basic Plan",
                        subtitle: "Premium plan for Free",
                        description:
                            "Get proper stock market tips and analysis",
                        price: "Free",
                        buttonColor: Colors.greenAccent.shade700,
                        onPressed: () async {
  final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          final existingRequest = await FirebaseFirestore.instance
                              .collection('requests')
                              .where('userId', isEqualTo: user.uid)
                              .where('groupName', isEqualTo: 'free')
                              .where('status', isEqualTo: 'pending')
                              .get();

                          if (existingRequest.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("⚠️ You already have a pending request."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();
                          final userData = userDoc.data() ?? {};

                          final request = {
                            'userId': user.uid,
                            'userName':
                                userData['name'] ?? user.displayName ?? 'User',
                            'userEmail': user.email ?? userData['email'] ?? '',
                            'groupName': 'free',
                            'type': 'Free Plan',
                            'status': 'pending',
                            'requestedAt': DateTime.now(),
                          };

                          await FirebaseFirestore.instance
                              .collection('requests')
                              .add(request);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "✅ Your request has been sent to the admin.",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      if (isWide)
                        const SizedBox(width: 18)
                      else
                        const SizedBox(height: 18),
                      _PlanCard(
                        icon: Icons.trending_up,
                        title: "Standard Plan",
                        subtitle: "Premium plan for one month",
                        description: "Get accurate stock market insights",
                        price: "₹1 / month",
                        buttonColor: Colors.blueAccent,
                        onPressed: () {
                          openCheckout(amount: "1", planType: "Standard Plan");
                        },
                      ),
                      if (isWide)
                        const SizedBox(width: 18)
                      else
                        const SizedBox(height: 18),
                      _PlanCard(
                        icon: Icons.workspace_premium,
                        title: "Premium Plan",
                        subtitle: "Premium plan for three months",
                        description: "Advanced stock trading analysis",
                        price: "₹1 / 3 months",
                        buttonColor: Colors.deepPurple,
                        onPressed: () {
                          openCheckout(amount: "1", planType: "Premium Plan");
                        },
                      ),
                    ],
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

class _PlanCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _PlanCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 400),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: buttonColor.withOpacity(0.12),
                child: Icon(icon, size: 32, color: buttonColor),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: buttonColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: buttonColor,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onPressed,
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
