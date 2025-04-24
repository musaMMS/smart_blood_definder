// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class PhoneAuthScreen extends StatefulWidget {
//   final String phone;
//
//   const PhoneAuthScreen({super.key, required this.phone});
//
//   @override
//   State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
// }
//
// class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
//   final TextEditingController otpController = TextEditingController();
//   String verificationId = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _verifyPhoneNumber();
//   }
//
//   void _verifyPhoneNumber() async {
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: '${widget.phone}',
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await FirebaseAuth.instance.signInWithCredential(credential);
//         Navigator.pushReplacementNamed(context, '/home');
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Verification Failed')));
//       },
//       codeSent: (String verId, int? resendToken) {
//         setState(() {
//           verificationId = verId;
//         });
//       },
//       codeAutoRetrievalTimeout: (String verId) {
//         verificationId = verId;
//       },
//     );
//   }
//
//   void _submitOTP() async {
//     final otp = otpController.text.trim();
//
//     PhoneAuthCredential credential = PhoneAuthProvider.credential(
//       verificationId: verificationId,
//       smsCode: otp,
//     );
//
//     try {
//       await FirebaseAuth.instance.signInWithCredential(credential);
//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Phone Verification')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text('Enter the OTP sent to +88${widget.phone}'),
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(labelText: 'OTP'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _submitOTP,
//               child: Text('Verify & Continue'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
