import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:app_develop/Screens/booking.dart';

class ServiceProviderLocation {
  final String id;
  final String name;
  final String serviceType;
  final double rating;
  final double pricePerHour;
  final double latitude;
  final double longitude;
  final String imageUrl;

  ServiceProviderLocation({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.rating,
    required this.pricePerHour,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  factory ServiceProviderLocation.fromJson(Map<String, dynamic> json) {
    // Extract location data safely with null checks
    final location = json['location'];
    double? lat, lng;
    
    if (location != null) {
      lat = location['latitude']?.toDouble();
      lng = location['longitude']?.toDouble();
    }

    return ServiceProviderLocation(
      id: json['service_provider_id'].toString(),
      name: json['businessName'] ?? 'Unknown Business',
      serviceType: json['serviceType'] ?? 'General Service',
      rating: (json['rating'] ?? 0).toDouble(),
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      latitude: lat ?? 0.0,
      longitude: lng ?? 0.0,
      imageUrl: json['profilePicture'] ?? '',
    );
  }

  bool hasValidLocation() {
    return latitude != 0.0 && longitude != 0.0;
  }
}

class MapScreen extends StatefulWidget {
  final String token;

  const MapScreen({super.key, required this.token});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<ServiceProviderLocation> _providers = [];
  bool _isLoading = true;
  bool _locationPermissionGranted = false;
  LatLng _currentUserLocation = const LatLng(5.6037, -0.1870); // Default to Accra, Ghana
  ServiceProviderLocation? _selectedProvider;
  bool _mapInitialized = false;
  bool _showServiceTypeLabels = true; // Toggle for showing/hiding service type labels

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _fetchServiceProviders();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationPermissionGranted = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationPermissionGranted = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationPermissionGranted = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.')),
        );
      }
      return;
    }

    setState(() {
      _locationPermissionGranted = true;
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentUserLocation = LatLng(position.latitude, position.longitude);
      });
      
      // Only move the map if it's already initialized
      if (_mapInitialized) {
        _mapController.move(_currentUserLocation, 13.0);
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  // Called when the map is ready
  void _onMapReady() {
    setState(() {
      _mapInitialized = true;
    });
    
    // Now that the map is ready, we can move to the current location
    if (_locationPermissionGranted) {
      _mapController.move(_currentUserLocation, 13.0);
    }
  }

  Future<void> _fetchServiceProviders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      const baseUrl = 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
      final response = await http.get(
        Uri.parse('$baseUrl/api/providers/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _providers = data
              .map((json) => ServiceProviderLocation.fromJson(json))
              .where((provider) => provider.hasValidLocation())
              .toList();
          _isLoading = false;
        });
        debugPrint('Fetched ${_providers.length} providers with valid locations');
      } else {
        debugPrint('Failed to load providers: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching providers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToBooking(String providerId) async {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(token: widget.token, providerId: providerId),
        ),
      );
    }
  }

  Widget _buildProviderInfoCard() {
    if (_selectedProvider == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildProviderAvatar(_selectedProvider!.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedProvider!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E5CE6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedProvider!.serviceType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5E5CE6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(
                    ' ${_selectedProvider!.rating.toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '₵${_selectedProvider!.pricePerHour.toStringAsFixed(2)}/hr',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E5CE6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToBooking(_selectedProvider!.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E5CE6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderAvatar(String imageUrl) {
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        radius: 24,
        child: Icon(
          CupertinoIcons.person_solid,
          color: Colors.grey.shade400,
          size: 30,
        ),
      );
    }

    try {
      if (imageUrl.startsWith('data:image')) {
        // Handle base64 image data
        final base64Str = imageUrl.split(',').last;
        return CircleAvatar(
          backgroundImage: MemoryImage(base64Decode(base64Str)),
          radius: 24,
        );
      } else {
        // Handle direct URLs
        return CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 24,
        );
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      return CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        radius: 24,
        child: Icon(
          CupertinoIcons.person_solid,
          color: Colors.grey.shade400,
          size: 30,
        ),
      );
    }
  }

  // Get the appropriate icon for each service type
  IconData _getServiceTypeIcon(String serviceType) {
    final String type = serviceType.trim().toLowerCase();
    
    // Exact matching for specific service types
    switch (type) {
      case 'plumber':
        return CupertinoIcons.drop;
      case 'electrician':
        return CupertinoIcons.bolt;
      case 'painter':
        return CupertinoIcons.paintbrush;
      case 'mechanic': 
      case 'auto body technician':
      case 'vehicle spray painter':
      case 'motorcycle repair technician':
        return CupertinoIcons.car;
      case 'carpenter':
      case 'furniture maker':
        return CupertinoIcons.hammer;
      case 'mason':
      case 'bricklayer':
      case 'tiler':
        return CupertinoIcons.building_2_fill;
      case 'welder':
      case 'blacksmith':
        return CupertinoIcons.flame;
      case 'gardener':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'cleaner':
      case 'housekeeper':
        return CupertinoIcons.sparkles;
      case 'tailor':
        return HugeIcons.strokeRoundedTapeMeasure;
      case 'hairdresser':
      case 'barber':
        return CupertinoIcons.scissors;
      case 'makeup artist':
        return CupertinoIcons.paintbrush_fill;
      case 'chef':
      case 'baker':
      case 'butcher':
        return CupertinoIcons.flame;
      case 'heavy equipment operator':
        return Icons.construction_outlined;
      case 'refrigeration and ac technician':
        return CupertinoIcons.snow;
      case 'upholsterer':
        return CupertinoIcons.bed_double;
      case 'roofer':
        return CupertinoIcons.house;
      case 'pest control technician':
        return CupertinoIcons.ant;
      case 'Icons.construction_outlined':
        return CupertinoIcons.helm;
      case 'shoemaker':
        return CupertinoIcons.tag;
      case 'laundry worker':
        return Icons.local_laundry_service;
      case 'solar panel installer':
        return CupertinoIcons.sun_max;
      case 'cctv installer':
        return CupertinoIcons.camera;
      case 'driver (commercial/private)':
        return CupertinoIcons.car_detailed;
      default:
        // For any unmatched service types, do partial matching
        if (type.contains('plumb')) {
          return CupertinoIcons.drop;
        } else if (type.contains('electric')) {
          return CupertinoIcons.bolt;
        } else if (type.contains('paint')) {
          return CupertinoIcons.paintbrush;
        } else if (type.contains('car') || type.contains('auto') || type.contains('vehicle') || type.contains('mechanic')) {
          return CupertinoIcons.car;
        } else if (type.contains('carpent') || type.contains('furniture')) {
          return CupertinoIcons.hammer;
        } else if (type.contains('mason') || type.contains('brick') || type.contains('tile')) {
          return CupertinoIcons.building_2_fill;
        } else if (type.contains('weld') || type.contains('metal')) {
          return CupertinoIcons.flame;
        } else if (type.contains('garden') || type.contains('landscap')) {
          return CupertinoIcons.leaf_arrow_circlepath;
        } else if (type.contains('clean') || type.contains('housekeep') || type.contains('maid')) {
          return CupertinoIcons.sparkles;
        } else if (type.contains('tailor') || type.contains('cloth') || type.contains('sew')) {
          return HugeIcons.strokeRoundedTapeMeasure;
        } else if (type.contains('hair') || type.contains('barber') || type.contains('salon')) {
          return CupertinoIcons.scissors;
        } else if (type.contains('makeup') || type.contains('beauty')) {
          return CupertinoIcons.paintbrush_fill;
        } else if (type.contains('chef') || type.contains('cook') || type.contains('bak') || type.contains('food')) {
          return CupertinoIcons.flame;
        } else if (type.contains('roof')) {
          return CupertinoIcons.house;
        } else if (type.contains('pest') || type.contains('insect')) {
          return CupertinoIcons.ant;
        } else if (type.contains('construct')) {
          return Icons.construction_outlined;
        } else if (type.contains('shoe')) {
          return CupertinoIcons.tag;
        } else if (type.contains('laundry') || type.contains('wash')) {
          return Icons.local_laundry_service;
        } else if (type.contains('solar') || type.contains('panel')) {
          return CupertinoIcons.sun_max;
        } else if (type.contains('cctv') || type.contains('camera') || type.contains('security')) {
          return CupertinoIcons.camera;
        } else if (type.contains('driv')) {
          return CupertinoIcons.car_detailed;
        }
        
        // Default icon if no match
        return CupertinoIcons.wrench_fill;
    }
  }

  // Get short service type name (for display on map)
  String _getShortServiceType(String serviceType) {
    final String type = serviceType.trim();
    
    // If the service type is longer than 12 characters, try to shorten it
    if (type.length > 12) {
      final String lowerType = type.toLowerCase();
      
      // Common abbreviations for longer service types
      if (lowerType.contains('electrician')) return 'Electrician';
      if (lowerType.contains('plumber')) return 'Plumber';
      if (lowerType.contains('mechanic')) return 'Mechanic';
      if (lowerType.contains('carpenter')) return 'Carpenter';
      if (lowerType.contains('painter')) return 'Painter';
      if (lowerType.contains('mason')) return 'Mason';
      if (lowerType.contains('welder')) return 'Welder';
      if (lowerType.contains('gardener')) return 'Gardener';
      if (lowerType.contains('cleaner')) return 'Cleaner';
      if (lowerType.contains('tailor')) return 'Tailor';
      if (lowerType.contains('hairdresser')) return 'Hair Stylist';
      if (lowerType.contains('barber')) return 'Barber';
      if (lowerType.contains('makeup')) return 'Makeup';
      if (lowerType.contains('chef')) return 'Chef';
      if (lowerType.contains('baker')) return 'Baker';
      if (lowerType.contains('refrigeration') || lowerType.contains('ac technician')) return 'AC Tech';
      if (lowerType.contains('cctv')) return 'CCTV';
      if (lowerType.contains('solar')) return 'Solar';
      if (lowerType.contains('driver')) return 'Driver';
      
      // Return first 10 chars + "..." for any other long service type
      return '${type.substring(0, 10)}...';
    }
    
    // Return the original if it's short enough
    return type;
  }

  // Build the service provider marker with label
  Widget _buildProviderMarker(ServiceProviderLocation provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The marker
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedProvider = provider;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5E5CE6).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF5E5CE6),
              child: Icon(
                _getServiceTypeIcon(provider.serviceType),
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        
        // Service type label (only if showing labels is enabled)
        if (_showServiceTypeLabels)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF5E5CE6), width: 1),
            ),
            child: Text(
              _getShortServiceType(provider.serviceType),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5E5CE6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Map',
          style: TextStyle(
            color: Color(0xFF5E5CE6),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Toggle service type labels
          IconButton(
            icon: Icon(
              _showServiceTypeLabels ? Icons.label : Icons.label_off,
              color: const Color(0xFF5E5CE6),
            ),
            onPressed: () {
              setState(() {
                _showServiceTypeLabels = !_showServiceTypeLabels;
              });
            },
            tooltip: _showServiceTypeLabels ? 'Hide service type labels' : 'Show service type labels',
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.location_fill,
              color: _locationPermissionGranted
                  ? const Color(0xFF5E5CE6)
                  : Colors.grey,
            ),
            onPressed: _locationPermissionGranted
                ? _getCurrentLocation
                : _checkLocationPermission,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF5E5CE6)),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentUserLocation,
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedProvider = null;
                      });
                    },
                    onMapReady: _onMapReady,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.nsaano.app',
                    ),
                    MarkerLayer(
                      markers: [
                        // Current user's location marker
                        Marker(
                          point: _currentUserLocation,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        // Service provider markers
                        ..._providers.map((provider) {
                          return Marker(
                            point: LatLng(provider.latitude, provider.longitude),
                            width: _showServiceTypeLabels ? 80 : 40, // Wider if showing labels
                            height: _showServiceTypeLabels ? 70 : 40, // Taller if showing labels
                            child: _buildProviderMarker(provider),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildProviderInfoCard(),
          ),
          if (_providers.isEmpty && !_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.map_pin_slash,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No service providers with location data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}