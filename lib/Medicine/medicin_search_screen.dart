import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Medicine_details.screen.dart';

class SearchMedicineScreen extends StatefulWidget {
  const SearchMedicineScreen({super.key});

  @override
  State<SearchMedicineScreen> createState() => _SearchMedicineScreenState();
}

class _SearchMedicineScreenState extends State<SearchMedicineScreen> {
  List medicines = [];
  List filteredMedicines = [];
  final TextEditingController searchController = TextEditingController();

  Future<void> fetchMedicines() async {
    final response = await http.get(
      Uri.parse('https://680365ea0a99cb7408ebddff.mockapi.io/medicines'),
    );

    if (response.statusCode == 200) {
      medicines = json.decode(response.body);
      setState(() {
        filteredMedicines = medicines;
      });
    } else {
      throw Exception('Failed to load medicines');
    }
  }

  void filterSearch(String query) {
    final results = medicines.where((med) {
      final name = med['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredMedicines = results;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Search Medicine')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: const InputDecoration(
                labelText: 'Search by medicine name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMedicines.length,
                itemBuilder: (context, index) {
                  final med = filteredMedicines[index];
                  return ListTile(
                    title: Text(med['name']),
                    subtitle: Text("Company: ${med['company']}"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MedicineDetailScreen(medicine: med),
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
