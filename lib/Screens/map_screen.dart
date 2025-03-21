import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_develop/models/service_provider.dart';
import 'package:app_develop/services/api_service.dart';
import 'package:app_develop/screens/provider_details_screen.dart';

class MapScreen extends StatefulWidget {
  final String token;

  const MapScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  late ApiService _apiService;
  LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(token: widget.token);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Load nearby providers
      _loadNearbyProviders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNearbyProviders() async {
    if (_currentLocation == null) return;

    try {
      final providers = await _apiService.getNearbyProviders(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        5000, // 5km radius
      );

      setState(() {
        _markers.clear();
        for (var provider in providers) {
          _markers.add(
            Marker(
              markerId: MarkerId(provider.id),
              position: provider.location,
              infoWindow: InfoWindow(
                title: provider.name,
                snippet: provider.category,
              ),
              onTap: () => _onMarkerTapped(provider),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getCategoryHue(provider.category),
              ),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading providers: $e')),
      );
    }
  }

  double _getCategoryHue(String category) {
    // Assign different colors for different categories
    switch (category.toLowerCase()) {
      case 'plumber':
        return BitmapDescriptor.hueBlue;
      case 'electrician':
        return BitmapDescriptor.hueYellow;
      case 'carpenter':
        return BitmapDescriptor.hueOrange;
      case 'tailor':
        return BitmapDescriptor.hueMagenta;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _onMarkerTapped(ServiceProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderDetailsScreen(
          providerId: provider.id,
          token: widget.token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentLocation == null) {
      return const Scaffold(
        body: Center(child: Text('Unable to get location')),
      );
    }

    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _currentLocation!,
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNearbyProviders,
        child: const Icon(Icons.refresh),
      ),
    );
  }
} 