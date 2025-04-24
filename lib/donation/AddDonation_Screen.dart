import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AddDonationScreen extends StatefulWidget {
  final String donorId; // Donor's Firestore ID
  const AddDonationScreen({super.key, required this.donorId});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  Future<void> submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection('donations').add({
      'donorId': widget.donorId,
      'receiverName': receiverNameController.text.trim(),
      'receiverPhone': receiverPhoneController.text.trim(),
      'hospital': hospitalController.text.trim(),
      'city': cityController.text.trim(),
      'date': Timestamp.now(),
      'status': 'Completed',
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Donation recorded')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Donation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: receiverNameController,
                decoration: InputDecoration(labelText: 'Receiver Name'),
                validator: (value) => value!.isEmpty ? 'Enter receiver name' : null,
              ),
              TextFormField(
                controller: receiverPhoneController,
                decoration: InputDecoration(labelText: 'Receiver Phone'),
                validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
              ),
              TextFormField(
                controller: hospitalController,
                decoration: InputDecoration(labelText: 'Hospital'),
                validator: (value) => value!.isEmpty ? 'Enter hospital name' : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Enter city' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitDonation,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
