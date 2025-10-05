// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// // UPI Constants
// const double maxUPILimit = 100000.0;
// const String bankLimitErrorCode = 'U13';
// const String insufficientFundsCode = 'U19';

// class UPIPaymentManager {
//   static const platform = MethodChannel('com.example.final_stock/upi');
//   static bool _isPaymentInProgress = false;

//   // Enhanced UPI Launch Function
//   static Future<void> launchUPI(
//     BuildContext context, {
//     required String payeeVPA,
//     required String payeeName,
//     required String amount,
//     String transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
//     try {
//       _isPaymentInProgress = true;

//       // Validate amount
//       final double parsedAmount = double.tryParse(amount) ?? 0.0;
//       if (parsedAmount <= 0 || parsedAmount > maxUPILimit) {
//         throw Exception('Invalid amount. Must be between ₹1 and ₹1,00,000');
//       }

//       // Warn for high amounts
//       if (parsedAmount > 5000) {
//         final proceed = await _showHighAmountWarning(context, amount);
//         if (!proceed) {
//           _isPaymentInProgress = false;
//           return;
//         }
//       }

//       // Create UPI URL with proper encoding
//       final upiUrl = _encodeUPIUrl(
//         payeeVPA: payeeVPA,
//         payeeName: payeeName,
//         amount: amount,
//         transactionNote: transactionNote,
//         transactionId: transactionId,
//       );

//       // Show payment loading
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Opening payment app...'),
//             ],
//           ),
//         ),
//       );

//       // Launch UPI via platform channel
//       await platform.invokeMethod('launchUPI', {
//         'uri': upiUrl,
//         'amount': amount,
//         'planType': planType,
//         'transactionId': transactionId,
//       });

//       // Close loading dialog
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       // Show payment instructions
//       await _showPaymentInstructions(context, amount, planType, transactionId);
//     } catch (e) {
//       _isPaymentInProgress = false;

//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Payment error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );

//       // Show fallback options
//       await _showUPIAppSelection(
//         context,
//         payeeVPA,
//         payeeName,
//         amount,
//         transactionNote,
//         planType,
//         transactionId,
//       );
//     }
//       );

//       // Show fallback options
//       await _showUPIAppSelection(
//         context,
//         payeeVPA,
//         payeeName,
//         amount,
//         transactionNote,
//         planType,
//         transactionId,
//       );
//     }
//   }

//   // Handle UPI Response from Platform Channel
//   static void handleUPIResponse(
//     BuildContext context, {
//     required Map<String, String> response,
//     required String amount,
//     required String planType,
//     required String transactionId,
//   }) async {
//     _isPaymentInProgress = false;

//     try {
//       final status =
//           response['Status']?.toUpperCase() ??
//           response['status']?.toUpperCase() ??
//           'UNKNOWN';
//       final responseCode =
//           response['responseCode'] ?? response['txnStatus'] ?? '';

//       debugPrint(
//         'Handling UPI Response: Status=$status, ResponseCode=$responseCode',
//       );

//       if (status == 'SUCCESS' || responseCode == '00') {
//         await _showPaymentVerificationDialog(
//           context,
//           amount,
//           planType,
//           transactionId,
//         );
//       } else if (status == 'FAILURE' ||
//           status == 'FAILED' ||
//           responseCode == 'U01' ||
//           responseCode == 'ZR') {
//         String errorMessage = 'Payment failed. Please try again.';
//         if (responseCode == bankLimitErrorCode) {
//           errorMessage =
//               'Payment failed: Daily UPI limit exceeded. Try again tomorrow or increase your bank limit.';
//         } else if (responseCode == insufficientFundsCode) {
//           errorMessage =
//               'Payment failed: Insufficient balance in your account.';
//         } else if (responseCode == 'U01' || responseCode == 'ZR') {
//           errorMessage = 'Payment failed: Transaction declined by bank or app.';
//         }

//         await _showPaymentFailureDialog(
//           context,
//           errorMessage,
//           amount,
//           planType,
//           transactionId,
//         );
//       } else {
//         // Payment status unknown, ask user to verify
//         await _showPaymentVerificationDialog(
//           context,
//           amount,
//           planType,
//           transactionId,
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error processing payment response: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Encode UPI URL
//   static String _encodeUPIUrl({
//     required String payeeVPA,
//     required String payeeName,
//     required String amount,
//     required String transactionNote,
//     required String transactionId,
//   }) {
//     final encodedPayeeVPA = Uri.encodeComponent(payeeVPA);
//     final encodedPayeeName = Uri.encodeComponent(payeeName);
//     final encodedAmount = Uri.encodeComponent(amount);
//     final encodedTransactionNote = Uri.encodeComponent(transactionNote);
//     final encodedTransactionId = Uri.encodeComponent(transactionId);

//     return 'upi://pay?pa=$encodedPayeeVPA&pn=$encodedPayeeName&am=$encodedAmount&cu=INR&tn=$encodedTransactionNote&tr=$encodedTransactionId';
//   }

//   // Show High Amount Warning
//   static Future<bool> _showHighAmountWarning(
//     BuildContext context,
//     String amount,
//   ) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => AlertDialog(
//             title: const Text('High Amount Warning'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('You are about to pay ₹$amount.'),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Note: Many banks have a daily UPI limit of ₹1,00,000. Ensure your bank allows this amount.',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'To increase limit, check your bank app (Profile > UPI Settings).',
//                   style: TextStyle(color: Colors.orange),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Proceed'),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   // Show Payment Instructions
//   static Future<void> _showPaymentInstructions(
//     BuildContext context,
//     String amount,
//     String planType,
//     String transactionId,
//   ) async {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             const Icon(Icons.payment, color: Colors.blue),
//             const SizedBox(width: 8),
//             const Text('Payment Instructions'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Amount: ₹$amount',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text('Plan: $planType'),
//                   Text(
//                     'Transaction ID: $transactionId',
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
//             const Text('1. Complete payment in the opened app'),
//             const Text('2. Return to this app after payment'),
//             const Text('3. We will verify your payment automatically'),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.orange),
//               ),
//               child: Text(
//                 '⚠️ Keep this app open and return after payment',
//                 style: TextStyle(
//                   color: Colors.orange[800],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _isPaymentInProgress = false;
//             },
//             child: const Text('Cancel Payment'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Got it'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show Payment Failure Dialog
//   static Future<void> _showPaymentFailureDialog(
//     BuildContext context,
//     String errorMessage,
//     String amount,
//     String planType,
//     String transactionId,
//   ) async {
//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             const Icon(Icons.error, color: Colors.red),
//             const SizedBox(width: 8),
//             const Text('Payment Failed'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(errorMessage),
//             const SizedBox(height: 16),
//             const Text('Would you like to try again with another app?'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _isPaymentInProgress = false;
//             },
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _showUPIAppSelection(
//                 context,
//                 'jaydarji1977@oksbi',
//                 'StockTrade',
//                 amount,
//                 'StockTrade $planType',
//                 planType,
//                 transactionId,
//               );
//             },
//             child: const Text('Try Another App'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               launchUrl(
//                 Uri.parse('https://pay.google.com/intl/en_in/about/'),
//                 mode: LaunchMode.externalApplication,
//               );
//             },
//             child: const Text('Contact Support'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show Payment Verification Dialog
//   static Future<void> _showPaymentVerificationDialog(
//     BuildContext context,
//     String amount,
//     String planType,
//     String transactionId,
//   ) async {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Verify Your Payment'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.help_outline, size: 48, color: Colors.orange),
//             const SizedBox(height: 16),
//             const Text('Please check your payment app and confirm:'),
//             const SizedBox(height: 8),
//             Text('Amount: ₹$amount'),
//             Text('Transaction ID: $transactionId'),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.red),
//               ),
//               child: Text(
//                 '⚠️ Only confirm if payment was actually successful in your payment app',
//                 style: TextStyle(
//                   color: Colors.red[800],
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _showPaymentFailureDialog(
//                 context,
//                 'Payment was not successful',
//                 amount,
//                 planType,
//                 transactionId,
//               );
//             },
//             child: const Text(
//               'Payment Failed',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             onPressed: () {
//               Navigator.pop(context);
//               _handlePaymentSuccess(context, amount, planType, transactionId);
//             },
//             child: const Text('Payment Successful'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Handle Payment Success
//   static Future<void> _handlePaymentSuccess(
//     BuildContext context,
//     String amount,
//     String planType,
//     String transactionId,
//   ) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         throw Exception('User not logged in');
//       }

//       // Get user data
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       final userData = userDoc.data();
//       final userName = userData?['name'] ?? 'User';

//       // Show success loading
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Processing your payment...'),
//             ],
//           ),
//         ),
//       );

//       // Create payment record
//       await FirebaseFirestore.instance.collection('payments').add({
//         'userId': user.uid,
//         'userName': userName,
//         'amount': double.parse(amount),
//         'planType': planType,
//         'status': 'completed',
//         'timestamp': FieldValue.serverTimestamp(),
//         'upiId': 'jaydarji1977@oksbi',
//         'transactionId': transactionId,
//         'verificationStatus': 'pending_admin_verification',
//       });

//       // Add to group with pending status
//       await FirebaseFirestore.instance
//           .collection('groups')
//           .doc('StockTrade')
//           .collection('members')
//           .doc(user.uid)
//           .set({
//             'userId': user.uid,
//             'userName': userName,
//             'joinedAt': FieldValue.serverTimestamp(),
//             'planType': planType,
//             'paymentAmount': double.parse(amount),
//             'status': 'pending_verification',
//             'transactionId': transactionId,
//           });

//       // Notify admin
//       await FirebaseFirestore.instance.collection('admin_notifications').add({
//         'type': 'payment_verification_required',
//         'userId': user.uid,
//         'userName': userName,
//         'planType': planType,
//         'amount': double.parse(amount),
//         'transactionId': transactionId,
//         'timestamp': FieldValue.serverTimestamp(),
//         'status': 'pending_verification',
//         'message': '$userName paid ₹$amount for $planType. TXN: $transactionId',
//       });

//       // Close loading dialog
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       // Show success message
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Row(
//             children: [
//               const Icon(Icons.check_circle, color: Colors.green),
//               const SizedBox(width: 8),
//               const Text('Payment Successful!'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Transaction ID: $transactionId'),
//               const SizedBox(height: 8),
//               const Text(
//                 'Your access will be activated after admin verification.',
//               ),
//             ],
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error processing payment: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Show UPI App Selection (Fallback)
//   static Future<void> _showUPIAppSelection(
//     BuildContext context,
//     String payeeVPA,
//     String payeeName,
//     String amount,
//     String transactionNote,
//     String planType,
//     String transactionId,
//   ) async {
//     final upiUrl = _encodeUPIUrl(
//       payeeVPA: payeeVPA,
//       payeeName: payeeName,
//       amount: amount,
//       transactionNote: transactionNote,
//       transactionId: transactionId,
//     );

//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Choose Payment App'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildUPIAppTile(
//               'Google Pay',
//               upiUrl,
//               Icons.account_balance_wallet,
//               Colors.blue,
//               context,
//               package: 'com.google.android.apps.nbu.paisa.user',
//             ),
//             _buildUPIAppTile(
//               'PhonePe',
//               upiUrl,
//               Icons.phone_android,
//               Colors.purple,
//               context,
//               package: 'com.phonepe.app',
//             ),
//             _buildUPIAppTile(
//               'Paytm',
//               upiUrl,
//               Icons.payment,
//               Colors.blue[900]!,
//               context,
//               package: 'net.one97.paytm',
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _isPaymentInProgress = false;
//             },
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildUPIAppTile(
//     String appName,
//     String upiUrl,
//     IconData icon,
//     Color color,
//     BuildContext context, {
//     String? package,
//   }) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: color.withOpacity(0.1),
//         child: Icon(icon, color: color),
//       ),
//       title: Text(appName),
//       onTap: () async {
//         Navigator.pop(context);
//         try {
//           final uri = Uri.parse(upiUrl);
//           await launchUrl(
//             uri,
//             mode: LaunchMode.externalApplication,
//             webViewConfiguration: const WebViewConfiguration(
//               enableJavaScript: true,
//               enableDomStorage: true,
//             ),
//           );
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('Opening $appName...')));
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Could not open $appName: $e')),
//           );
//           _isPaymentInProgress = false;
//         }
//       },
//     );
//   }

//   // Free Plan Join Function
//   static Future<void> handleFreePlanJoin(BuildContext context) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('User not logged in. Please login again.'),
//         ),
//       );
//       return;
//     }

//     try {
//       // Check if user is already in the group
//       final existingMember = await FirebaseFirestore.instance
//           .collection('groups')
//           .doc('StockTrade')
//           .collection('members')
//           .doc(user.uid)
//           .get();

//       if (existingMember.exists) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Row(
//               children: [
//                 const Icon(Icons.info, color: Colors.blue),
//                 const SizedBox(width: 8),
//                 const Text('Already a Member'),
//               ],
//             ),
//             content: const Text('You are already a member of the Free group!'),
//             actions: [
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//         return;
//       }

//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       final userName = userDoc.data()?['name'] ?? 'User';
//       final userEmail = userDoc.data()?['email'] ?? '';

//       // Add request to admin panel
//       await FirebaseFirestore.instance.collection('requests').add({
//         'userId': user.uid,
//         'userName': userName,
//         'userEmail': userEmail,
//         'groupName': 'free',
//         'type': 'Basic Plan (Free)',
//         'status': 'pending',
//         'requestedAt': FieldValue.serverTimestamp(),
//       });

//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Row(
//             children: [
//               const Icon(Icons.check_circle, color: Colors.green),
//               const SizedBox(width: 8),
//               const Text('Request Submitted'),
//             ],
//           ),
//           content: const Text(
//             'Your free plan request has been submitted. You will get access once approved by admin.',
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error submitting request: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }

// // Export functions for backward compatibility
// Future<void> launchUPI(
//   BuildContext context, {
//   required String payeeVPA,
//   required String payeeName,
//   required String amount,
//   required String transactionNote,
//   required String planType,
//   required int requestCode,
// }) => UPIPaymentManager.launchUPI(
//   context,
//   payeeVPA: payeeVPA,
//   payeeName: payeeName,
//   amount: amount,
//   transactionNote: transactionNote,
//   planType: planType,
//   requestCode: requestCode,
// );

// void handleUPIResponse(
//   BuildContext context, {
//   required Map<String, String> response,
//   required String amount,
//   required String planType,
//   required String transactionId,
// }) => UPIPaymentManager.handleUPIResponse(
//   context,
//   response: response,
//   amount: amount,
//   planType: planType,
//   transactionId: transactionId,
// );

// Future<void> handleFreePlanJoin(BuildContext context) =>
//     UPIPaymentManager.handleFreePlanJoin(context);
