class DashboardData {
  final int totalBookings;
  final int pendingBookings;
  final int completedBookings;
  final double totalEarnings;
  final List<Map<String, dynamic>> recentBookings;

  DashboardData({
    required this.totalBookings,
    required this.pendingBookings,
    required this.completedBookings,
    required this.totalEarnings,
    required this.recentBookings,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalBookings: json['totalBookings'] ?? 0,
      pendingBookings: json['pendingBookings'] ?? 0,
      completedBookings: json['completedBookings'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      recentBookings: List<Map<String, dynamic>>.from(json['recentBookings'] ?? []),
    );
  }
} 