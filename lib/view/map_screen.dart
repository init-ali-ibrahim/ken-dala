import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? selectedLocation;
  var _lastTap = 'аддресс';

  void _handleTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
    });
    _getAddressFromLatLng(latLng);
    print('Вы нажали на карту: ${latLng.latitude}, ${latLng.longitude}');
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}';

    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data['display_name'];
      setState(() {
        _lastTap = 'Адрес: $address';
      });
    } else {
      setState(() {
        _lastTap = 'Ошибка получения адреса';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('data'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(43.2565, 76.9285),
              initialZoom: 13.0,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_map_example',
              ),
            ],
          ),
          const Center(
            child: Icon(Icons.location_on, color: Colors.red, size: 40.0),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 1)),
        ),
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              _lastTap, // Показываем текст с адресом или ошибкой
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              // Здесь можно добавить дополнительное действие
            },
          ),
        ),
      ),
    );
  }
}
