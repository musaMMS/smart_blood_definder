import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final List<Hospital> hospitals = [
    Hospital(
      name: 'City Hospital',
      address: '456 Elm St',
      distance: '0.5 mi',
      location: LatLng(23.8103, 90.4125),
      phone: '999',
    ),
    Hospital(
      name: 'General Hospital',
      address: '789 Oak St',
      distance: '1.2 mi',
      location: LatLng(23.8203, 90.4225),
      phone: '995',
    ),
    Hospital(
      name: 'St. Mary\'s Hospital',
      address: '101 Pine St',
      distance: '2.3 mi',
      location: LatLng(23.8303, 90.4325),
      phone: '993',
    ),
  ];

  bool isFullScreenMap = false;
  String searchText = "";
  final mapController = MapController();
  TextEditingController searchController = TextEditingController();

  void callHospital(String phoneNumber) async {
    final Uri phoneUri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch call')),
      );
    }
  }

  Future<void> searchCity(String cityName) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        final cityLatLng = LatLng(locations[0].latitude, locations[0].longitude);
        mapController.move(cityLatLng, 13);
        setState(() {
          searchText = cityName;
        });
      }
    } catch (e) {
      print("Location not found: $e");
    }
  }

  List<Hospital> get filteredHospitals {
    if (searchText.isEmpty) return hospitals;
    return hospitals.where((h) =>
    h.name.toLowerCase().contains(searchText.toLowerCase()) ||
        h.address.toLowerCase().contains(searchText.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Hospitals')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => searchCity(searchController.text),
                ),
              ),
              onSubmitted: (value) => searchCity(value),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: isFullScreenMap ? MediaQuery.of(context).size.height * 0.75 : 200,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: hospitals[0].location,
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.smart_blood_definder',
                    ),
                    MarkerLayer(
                      markers: hospitals.map((hospital) {
                        return Marker(
                          width: 40.0,
                          height: 40.0,
                          point: hospital.location,
                          child: Icon(Icons.add_location_alt, color: Colors.red, size: 40),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(isFullScreenMap ? Icons.fullscreen_exit : Icons.fullscreen),
                      onPressed: () {
                        setState(() {
                          isFullScreenMap = !isFullScreenMap;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isFullScreenMap)
            Expanded(
              child: ListView.builder(
                itemCount: filteredHospitals.length,
                itemBuilder: (context, index) {
                  final hospital = filteredHospitals[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(hospital.name),
                      subtitle: Text(hospital.address),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(hospital.distance),
                          IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () => callHospital(hospital.phone),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class Hospital {
  final String name;
  final String address;
  final String distance;
  final LatLng location;
  final String phone;

  Hospital({
    required this.name,
    required this.address,
    required this.distance,
    required this.location,
    required this.phone,
  });
}
