import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return null;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          'Location permissions are permanently denied. We cannot request permissions.');
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint(
          'Current Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }
}

// Example of how to use this function and store in Firestore:
class LocationDisplayWidget extends StatefulWidget {
  const LocationDisplayWidget({super.key});

  @override
  State<LocationDisplayWidget> createState() => _LocationDisplayWidgetState();
}

class _LocationDisplayWidgetState extends State<LocationDisplayWidget> {
  String _locationMessage = 'Press the button to get location';
  bool _isLoading = false;

  // Get a reference to the Firestore collection
  final CollectionReference _userLocations =
      FirebaseFirestore.instance.collection('user_locations');

  Future<void> _getLocationAndSave() async {
    setState(() {
      _isLoading = true;
      _locationMessage = 'Getting location and saving...';
    });

    Position? position = await LocationService.getCurrentLocation();

    print(position!.longitude + position.latitude);

    if (position != null) {
      String? cityName;
      String? villageName; // Often available as subLocality or locality
      String? postalCode;

      try {
        // Perform reverse geocoding
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        print(placemarks.first);

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          cityName = place.locality ?? place.subAdministrativeArea; // City
          villageName =
              place.subLocality ?? place.locality; // Village/Sub-locality
          postalCode = place.postalCode;
          debugPrint('Address: $cityName, $villageName, $postalCode');
        } else {
          debugPrint('No placemarks found for coordinates.');
        }
      } catch (e) {
        debugPrint('Error during reverse geocoding: $e');
        // Continue even if geocoding fails, store just lat/lng
      }

      try {
        // Store the location and address details in Firestore
        await _userLocations.add({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': FieldValue.serverTimestamp(), // Still recommended
          'accuracy': position.accuracy, // Still recommended
          'city': cityName,
          'village':
              villageName, // Or 'subLocality' or 'locality' depending on your preference
          'postalCode': postalCode,
          // 'userId': 'your_user_id_here', // Add if you have authentication
        });
        _locationMessage = 'Location saved!\n'
            'Latitude: ${position.latitude}\n'
            'Longitude: ${position.longitude}\n'
            'City: ${cityName ?? 'N/A'}\n'
            'Village: ${villageName ?? 'N/A'}\n'
            'Pincode: ${postalCode ?? 'N/A'}';
      } catch (e) {
        _locationMessage = 'Failed to save location to Firestore: $e';
        debugPrint('Firestore save error: $e');
      }
    } else {
      _locationMessage = 'Failed to get location. Check logs for details.';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location & Address Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _locationMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _getLocationAndSave,
                    child: const Text('Get & Save Location with Address'),
                  ),
          ],
        ),
      ),
    );
  }
}
