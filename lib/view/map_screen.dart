import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  final storage = const FlutterSecureStorage();
  String _selectedStreet = '';
  String _selectedDistrict = '';
  final LatLng _center = const LatLng(43.220189, 76.876802);

  Future<void> _setMarkerIcon() async {
    _getAddressFromLatLng(_center);
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      Placemark place = placemarks[0];
      setState(() async {
        _selectedStreet = '${place.street}';
        _selectedDistrict = '${place.subLocality}';
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _setMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта'),
      ),
      body: SlidingUpPanel(
        boxShadow: const [
          BoxShadow(
            blurRadius: 0.0,
            color: Color.fromRGBO(0, 0, 0, 0),
          )
        ],
        
        header: Text('data'),
        
        panel: BottomSheet(
          shadowColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Colors.white,
          onClosing: () {},
          builder: (context) {
            return Container(
              height: 100,
              child: TextButton(
                  onPressed: () async {
                    await _getAddressFromLatLng(_markers.first.position);
                    await storage.write(key: 'streetCart', value: _selectedStreet);
                    await storage.write(key: 'districtCart', value: _selectedDistrict);

                    print('Выбран адрес: $_selectedStreet, $_selectedDistrict');
                  },
                  child: const Text('data')),
            );
          },
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                print('Google Map создан успешно');
              },
              markers: _markers,
              onCameraMove: (CameraPosition position) {
                setState(() {
                  _markers = {
                    Marker(markerId: const MarkerId('center_marker'), position: position.target, alpha: 0),
                  };
                });
              },
            ),
            const Positioned.fill(
              top: -35,
              child: Align(
                alignment: Alignment.center,
                child: Icon(Icons.location_on, size: 50, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
