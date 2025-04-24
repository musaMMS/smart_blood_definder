// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class MedicineDetailsScreen extends StatelessWidget {
//   final String medicineName;
//
//   MedicineDetailsScreen({required this.medicineName});
//
//
//   Future<Map<String, dynamic>?> fetchMedicineDetails(String medicineName) async {
//     final String username = 'your_username';
//     final String password = 'your_password';
//     final String baseUrl = 'https://info.shr.dghs.gov.bd/openmrs/ws/rest/v1/tr/drugs/';
//     final String url = '$baseUrl$medicineName';
//
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Basic ' + base64Encode(utf8.encode('$username:$password')),
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       return null;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: Text(medicineName)),
//       body: FutureBuilder<Map<String, dynamic>?>(
//         future: fetchMedicineDetails(medicineName),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError || !snapshot.hasData) {
//             return Center(child: Text('তথ্য পাওয়া যায়নি।'));
//           } else {
//             final medicine = snapshot.data!;
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('নাম: ${medicine['name'] ?? 'অজানা'}'),
//                   Text('জেনেরিক নাম: ${medicine['code']['coding'][0]['display'] ?? 'অজানা'}'),
//                   Text('ডোজ: ${medicine['code']['valueString'] ?? 'অজানা'}'),
//                   Text('প্রস্তুতকারক: ${medicine['manufacturer'] ?? 'অজানা'}'),
//                   Text('প্রাইস: ${medicine['price'] ?? 'অজানা'}'),
//                   Text('ব্যবহার: ${medicine['uses'] ?? 'অজানা'}'),
//                   Text('পার্শ্বপ্রতিক্রিয়া: ${medicine['sideEffects'] ?? 'অজানা'}'),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
