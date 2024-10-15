import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  bool _showZoomHint = false;

  Future<void> _setMarkerIcon() async {
    _getAddressFromLatLng(_center);
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      Placemark place = placemarks[0];

      if (place.street != null && !_isPlusCode(place.street!)) {
        setState(() {
          _selectedStreet = '${place.street}';
          _selectedDistrict = '${place.subLocality}';
        });
      } else {
        setState(() {
          _selectedStreet = 'Адрес недоступен';
          _selectedDistrict = '${place.subLocality}';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  bool _isPlusCode(String street) {
    final plusCodePattern = RegExp(r'^[A-Z0-9+]{4,}$');
    return plusCodePattern.hasMatch(street);
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: const BorderRadius.all(Radius.circular(99)),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF4F4F6),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const Text(
                'Карта',
                style: TextStyle(color: Colors.black),
              ),
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(99)),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
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

              _getAddressFromLatLng(position.target);

              if (position.zoom < 17) {
                setState(() {
                  _showZoomHint = true;
                });
              } else {
                setState(() {
                  _showZoomHint = false;
                });
              }

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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey, width: 1))),
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 65,
              child: TextButton(
                style: _showZoomHint
                    ? TextButton.styleFrom(backgroundColor: Colors.grey, padding: const EdgeInsets.all(20), maximumSize: const Size.fromWidth(400))
                    : TextButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(20), maximumSize: const Size.fromWidth(400)),
                onPressed: () async {
                  if (!_showZoomHint) {
                    await storage.write(key: 'streetCart', value: _selectedStreet);
                    await storage.write(key: 'districtCart', value: _selectedDistrict);
                    print('Выбран адрес: $_selectedStreet, $_selectedDistrict');
                  }

                  // await _getAddressFromLatLng(_markers.first.position);
                  // await storage.write(key: 'streetCart', value: _selectedStreet);
                  // await storage.write(key: 'districtCart', value: _selectedDistrict);
                  //
                  // print('Выбран адрес: $_selectedStreet, $_selectedDistrict');
                },
                child: _showZoomHint
                    ? const Text(
                        'Приблизьтесь',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )
                    : Text(
                        'Выбран адрес: $_selectedStreet, $_selectedDistrict',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
