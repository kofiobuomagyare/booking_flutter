import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceProvider {
  final int id;
  final String businessName;
  final String email;
  final String phoneNumber;
  final String serviceType;
  final String location;
  final String? profilePicture;
  final String serviceProviderId;

  ServiceProvider({
    required this.id,
    required this.businessName,
    required this.email,
    required this.phoneNumber,
    required this.serviceType,
    required this.location,
    this.profilePicture,
    required this.serviceProviderId,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'],
      businessName: json['businessName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      serviceType: json['serviceType'],
      location: json['location'],
      profilePicture: json['profilePicture'],
      serviceProviderId: json['service_provider_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessName': businessName,
      'email': email,
      'phoneNumber': phoneNumber,
      'serviceType': serviceType,
      'location': location,
      'profilePicture': profilePicture,
      'service_provider_id': serviceProviderId,
    };
  }
} 