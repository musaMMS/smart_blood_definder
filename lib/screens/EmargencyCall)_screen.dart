import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCallScreen extends StatelessWidget {
  final List<Map<String, String>> emergencyNumbers = [
    {'title': '🔥 ফায়ার সার্ভিস', 'number': '995'},
    {'title': '🚓 পুলিশ', 'number': '999'},
    {'title': '🚑 অ্যাম্বুলেন্স', 'number': '999'},
    {'title': '🚨 জাতীয় জরুরি সেবা', 'number': '999'},
    {'title': '🏥 স্বাস্থ্য বাতায়ন', 'number': '16263'},
    {'title': '☎️ সরকারি তথ্যসেবা', 'number': '333'},
    {'title': '📱 টেলিটক হেল্পলাইন', 'number': '121'},
    {'title': '🧒 শিশু সহায়তা', 'number': '1098'},
    {'title': '👩 নারী সহায়তা', 'number': '109'},
    {'title': '💊 ওষুধ তথ্য', 'number': '16267'},
    {'title': '🦠 করোনা হেল্পলাইন', 'number': '10655'},
    {'title': '💻 সাইবার ক্রাইম অভিযোগ', 'number': '01320082038'},
  ];

    EmergencyCallScreen({super.key});

  void _makePhoneCall(String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $number';
    }
  }
  void makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('জরুরি কল নম্বর'),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: emergencyNumbers.length,
        itemBuilder: (context, index) {
          final item = emergencyNumbers[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 4,
            child: ListTile(
              leading: Icon(Icons.phone, color: Colors.red),
              title: Text(item['title']!, style: TextStyle(fontSize: 18)),
              subtitle: Text('কল করুন: ${item['number']}'),
              trailing: IconButton(
                icon: Icon(Icons.call, color: Colors.green),
                onPressed: () => _makePhoneCall(item['number']!),
              ),
            ),
          );
        },
      ),
    );
  }
}
