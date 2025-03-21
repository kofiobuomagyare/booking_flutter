
class ServiceProvider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String serviceType;
  final String? profileImage;
  final double rating;
  final int totalReviews;
  final bool isAvailable;
  final List<String>? serviceAreas;
  final Map<String, dynamic>? location;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.serviceType,
    this.profileImage,
    required this.rating,
    required this.totalReviews,
    required this.isAvailable,
    this.serviceAreas,
    this.location,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      serviceType: json['serviceType'],
      profileImage: json['profileImage'],
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      serviceAreas: json['serviceAreas']?.cast<String>(),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'serviceType': serviceType,
      'profileImage': profileImage,
      'rating': rating,
      'totalReviews': totalReviews,
      'isAvailable': isAvailable,
      'serviceAreas': serviceAreas,
      'location': location,
    };
  }

  ServiceProvider copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? serviceType,
    String? profileImage,
    double? rating,
    int? totalReviews,
    bool? isAvailable,
    List<String>? serviceAreas,
    Map<String, dynamic>? location,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      serviceType: serviceType ?? this.serviceType,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isAvailable: isAvailable ?? this.isAvailable,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      location: location ?? this.location,
    );
  }
} 