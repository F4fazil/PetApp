import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petpalace/Database/database.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  bool _isDialogShowing = false;
  String stAddress = "Loading..";
  String phone = "03016521617";
  bool bToggle = true;
  final Completer<GoogleMapController> _mapController = Completer();
  static const LatLng _googlePlex = LatLng(31.446, 74.2682);
  LatLng? _currentPosition;
  final List<Marker> _markers = <Marker>[];
  BitmapDescriptor? customMarker;
  @override
  Future<void> _loadCustomMarker() async {
    customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/rabbit.png',
      width: 60,
      height: 60,
    );
    setState(() {});
  }

  void showTrackingDialog(BuildContext context) {
    if (!_isDialogShowing) {
      _isDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing manually
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Row(
              children: [
                Icon(Icons.pets, color: Colors.orange),
                SizedBox(width: 25),
                Text("Tracking Your Pet", style: TextStyle(fontSize: 15)),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.orange),
                SizedBox(height: 15),
                Text(
                  "Locating your pet...\nStay tuned for updates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void closeTrackingDialog() {
    if (_isDialogShowing) {
      _isDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> loadData() async {
    try {
      // Step 1: Get the current position
      final Position position = await _determinePosition();
      final LatLng currentPosition = LatLng(
        position.latitude,
        position.longitude,
      );

      // Step 2: Get the address from coordinates
      final String address = await _getAddressFromCoordinates(position);

      // Step 3: Update the map with the current location
      await _updateMap(currentPosition, address);

      // Step 4: Move the camera to the current location
      await _moveCameraToLocation(currentPosition);
    } catch (e) {
      print("Error loading data: $e");
      // Show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load location data: ${e.toString()}"),
        ),
      );
    }
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final Placemark placemark = placemarks.first;
      return "${placemark.subThoroughfare}, ${placemark.subLocality}, ${placemark.locality}";
    } catch (e) {
      print("Error fetching address: $e");
      return "Unknown Address";
    }
  }

  Future<void> _updateMap(LatLng currentPosition, String address) async {
    setState(() {
      _currentPosition = currentPosition;
      stAddress = address;

      // Clear previous markers and add a new one
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: currentPosition,
          infoWindow: InfoWindow(title: stAddress),
          icon:
              bToggle
                  ? (customMarker ?? BitmapDescriptor.defaultMarker)
                  : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
        ),
      );
    });
  }

  Future<void> _moveCameraToLocation(LatLng currentPosition) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentPosition, zoom: 16),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in the app settings.',
      );
    }

    // Get the current position
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    loadData();
    _loadCustomMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DataBaseStorage().retrieveAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            Future.delayed(Duration.zero, () {
              showTrackingDialog(context);
            });

            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
            );
          } else {
            Future.delayed(
              Duration.zero,
              closeTrackingDialog,
            ); // Close dialog when data is ready
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Stack(
              children: [
                GoogleMap(
                  onMapCreated:
                      (GoogleMapController controller) =>
                          _mapController.complete(controller),
                  mapType: MapType.terrain,
                  initialCameraPosition: const CameraPosition(
                    target: _googlePlex,
                    zoom: 16,
                  ),
                  markers: Set<Marker>.of(_markers),
                ),
                Positioned(
                  top: 40,
                  left: 35,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 41, 116, 112),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "📍$stAddress",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 17, 160, 141),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          loadData();
        },
        label: const Text(
          "Track My Pet",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.location_on, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 41, 116, 112),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
