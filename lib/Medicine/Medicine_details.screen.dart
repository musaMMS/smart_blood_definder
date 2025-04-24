import 'package:flutter/material.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Map medicine;
  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(medicine['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${medicine['name']}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Company: ${medicine['company']}"),
            SizedBox(height: 10),
            Text("Uses: ${medicine['uses']}"),
            SizedBox(height: 10),
            Text("Price: ৳${medicine['price']}"),
            SizedBox(height: 10),
            Text("Stock: ${medicine['stock'] ? 'Available' : 'Out of stock'}"),
          ],
        ),
      ),
    );
  }
}
