import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/service_provider.dart';
import '../services/api_service.dart';
import '../screens/provider_details_screen.dart';

class MapScreen extends StatefulWidget {
  final String token;

  const MapScreen({
    super.key,
    required this.token,
  });

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
    _apiService = ApiService();
    _apiService.setAuthToken(widget.token);
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Load nearby providers
      _loadNearbyProviders();
    } catch (e) {
      if (!mounted) return;
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

      if (!mounted) return;

      setState(() {
        _markers.clear();
        for (var provider in providers) {
          _addProviderMarker(provider);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading providers: $e')),
      );
    }
  }

  void _addProviderMarker(ServiceProvider provider) {
    if (provider.location != null) {
      final lat = provider.location!['latitude'] as double;
      final lng = provider.location!['longitude'] as double;
      
      _markers.add(
        Marker(
          markerId: MarkerId(provider.id),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: provider.name,
            snippet: provider.serviceType,
          ),
          onTap: () => _onMarkerTapped(provider),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getCategoryHue(provider.serviceType),
          ),
        ),
      );
    }
  }

  double _getCategoryHue(String serviceType) {
    // Assign different colors for different service types
    switch (serviceType.toLowerCase()) {
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