// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Map<String, Work> trackedWorks = {};
  LatLng? currentLocation;
  double searchRadius = 5000; // 5km radius

  // Sample work data - replace with your actual data
  final List<Work> availableWorks = [
    Work(
      id: '1',
      title: 'Plumbing Service',
      location: const LatLng(37.42796133580664, -122.085749655962),
      provider: 'John Doe',
      status: WorkStatus.available,
      price: 75.0,
      category: 'Plumbing',
    ),
    Work(
      id: '2',
      title: 'Electrical Repair',
      location: const LatLng(37.42896133580664, -122.084749655962),
      provider: 'Jane Smith',
      status: WorkStatus.available,
      price: 90.0,
      category: 'Electrical',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackBar("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar("Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackBar("Location permissions are permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 14,
          ),
        ),
      );

      _updateNearbyServices();
    } catch (e) {
      _showErrorSnackBar("Error getting location: $e");
    }
  }

  void _updateNearbyServices() {
    if (currentLocation == null) return;

    setState(() {
      markers = availableWorks.where((work) {
        double distance = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          work.location.latitude,
          work.location.longitude,
        );
        return distance <= searchRadius;
      }).map((work) {
        return _createMarker(work);
      }).toSet();
    });
  }

  Marker _createMarker(Work work) {
    return Marker(
      markerId: MarkerId(work.id),
      position: work.location,
      infoWindow: InfoWindow(
        title: work.title,
        snippet: '${work.provider} - \$${work.price}',
      ),
      icon: work.status == WorkStatus.inProgress 
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          : BitmapDescriptor.defaultMarker,
      onTap: () => _showServiceDetails(work),
    );
  }

  void _loadMarkers() {
    setState(() {
      markers = availableWorks.map((work) => _createMarker(work)).toSet();
    });
  }

  void _showServiceDetails(Work work) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.6,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                work.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Provider: ${work.provider}'),
              Text('Category: ${work.category}'),
              Text('Price: \$${work.price}'),
              const SizedBox(height: 16),
              if (work.status == WorkStatus.available)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _bookService(work),
                    child: const Text('Book Now'),
                  ),
                )
              else if (trackedWorks.containsKey(work.id))
                Column(
                  children: [
                    Text('Status: ${work.status.toString().split('.').last}'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _getWorkProgress(work),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _getWorkProgress(Work work) {
    // Implement actual progress calculation based on your business logic
    return 0.6; // Sample progress (60%)
  }

  void _bookService(Work work) {
    setState(() {
      work.status = WorkStatus.inProgress;
      trackedWorks[work.id] = work;
      _loadMarkers(); // Refresh markers to update colors
    });
    
    Navigator.pop(context);
    _showSuccessSnackBar('Booked ${work.title}');
    
    // Simulate service progress updates
    _simulateServiceProgress(work);
  }

  void _simulateServiceProgress(Work work) {
    // This is a sample implementation - replace with actual tracking logic
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          work.status = WorkStatus.completed;
          _loadMarkers();
        });
        _showSuccessSnackBar('${work.title} has been completed!');
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          if (trackedWorks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showTrackedServices,
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 14,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onCameraMove: (position) {
              // Update services when map is moved
              searchRadius = 5000 * (15 / position.zoom); // Adjust radius based on zoom
              _updateNearbyServices();
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Services within ${(searchRadius/1000).toStringAsFixed(1)}km',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTrackedServices() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: trackedWorks.length,
        itemBuilder: (context, index) {
          Work work = trackedWorks.values.elementAt(index);
          return ListTile(
            title: Text(work.title),
            subtitle: Text('Status: ${work.status.toString().split('.').last}'),
            trailing: work.status == WorkStatus.inProgress
                ? const CircularProgressIndicator()
                : const Icon(Icons.check_circle, color: Colors.green),
            onTap: () => _showServiceDetails(work),
          );
        },
      ),
    );
  }
}

enum WorkStatus {
  available,
  inProgress,
  completed,
}

class Work {
  final String id;
  final String title;
  final LatLng location;
  final String provider;
  final double price;
  final String category;
  WorkStatus status;

  Work({
    required this.id,
    required this.title,
    required this.location,
    required this.provider,
    required this.price,
    required this.category,
    this.status = WorkStatus.available,
  });
}