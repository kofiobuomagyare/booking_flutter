// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ExploreScreen extends StatefulWidget {
  final String token;

  const ExploreScreen({super.key, required this.token});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  GoogleMapController? mapController; // Nullable to avoid late initialization error
  Set<Marker> markers = {};
  Map<String, Work> trackedWorks = {};
  LatLng? currentLocation;
  double searchRadius = 5000; // 5km radius

  final List<Work> availableWorks = [
    Work(
      id: '1',
      title: 'Plumbing Service',
      location: const LatLng(5.6145, -0.2057), // Accra
      provider: 'Kwame Mensah',
      status: WorkStatus.available,
      price: 75.0,
      category: 'Plumbing',
    ),
    Work(
      id: '2',
      title: 'Electrical Repair',
      location: const LatLng(5.6708, -0.0166), // Tema
      provider: 'Ama Boateng',
      status: WorkStatus.available,
      price: 90.0,
      category: 'Electrical',
    ),
    Work(
      id: '3',
      title: 'Carpentry Service',
      location: const LatLng(5.5933, -0.2672), // Achimota
      provider: 'Yaw Asare',
      status: WorkStatus.available,
      price: 60.0,
      category: 'Carpentry',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint("Current Location: ${position.latitude}, ${position.longitude}");

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation!,
              zoom: 14,
            ),
          ),
        );
      }

      _updateNearbyServices();
    } catch (e) {
      _showErrorSnackBar("Error getting location: $e");
    }
  }

  void _updateNearbyServices() {
    if (currentLocation == null) {
      debugPrint("Current location is null");
      return;
    }
  
    debugPrint("Updating services near: ${currentLocation!.latitude}, ${currentLocation!.longitude}");

    setState(() {
      markers = availableWorks.where((work) {
        double distance = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          work.location.latitude,
          work.location.longitude,
        );
        debugPrint("Work: ${work.title}, Distance: $distance meters");
        return distance <= searchRadius;
      }).map((work) => _createMarker(work)).toSet();
    });

    debugPrint("Total markers added: ${markers.length}");
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

  void _showServiceDetails(Work work) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(work.title, style: Theme.of(context).textTheme.headlineSmall),
            Text('Provider: ${work.provider}'),
            Text('Price: \$${work.price}'),
            ElevatedButton(
              onPressed: () => _bookService(work),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _bookService(Work work) {
    setState(() {
      work.status = WorkStatus.inProgress;
      trackedWorks[work.id] = work;
      _updateNearbyServices();
    });
    Navigator.pop(context);
    _showSuccessSnackBar('Booked ${work.title}');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
          _updateNearbyServices();
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(5.6037, -0.1870), // Default to Accra
          zoom: 14,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

enum WorkStatus { available, inProgress, completed }

class Work {
  final String id, title, provider, category;
  final LatLng location;
  final double price;
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
