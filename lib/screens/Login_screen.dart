import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();

  final List<String> countryCodes = ['+880', '+91', '+1', '+44', '+61'];
  String? selectedCountryCode;

  Future<void> loginUser() async {
    if (!loginFormKey.currentState!.validate()) return;

    String phone = selectedCountryCode! + phoneController.text.trim();

    try {
      // Firestore query
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // 🔹 Save name to SharedPreferences
        String name = snapshot.docs.first['name'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', name);

        // 🔹 Navigate to HomeScreen
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Login successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ No user found with this phone number')),
        );
      }
    } catch (e) {
      debugPrint("❌ Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: loginFormKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedCountryCode,
                decoration: const InputDecoration(labelText: 'Country Code'),
                items: countryCodes.map((code) {
                  return DropdownMenuItem(value: code, child: Text(code));
                }).toList(),
                onChanged: (value) => setState(() => selectedCountryCode = value),
                validator: (value) => value == null ? 'Select country code' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value == null || value.isEmpty ? 'Enter your phone number' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loginUser,
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
