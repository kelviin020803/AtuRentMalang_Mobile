class LocationModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final DateTime timestamp;
  final String provider; // 'GPS' atau 'Network'

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.timestamp,
    required this.provider,
  });

  // Convert ke Map (untuk keperluan logging/debug)
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
      'provider': provider,
    };
  }

  // Format koordinat untuk ditampilkan
  String get formattedCoordinates {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Format akurasi untuk ditampilkan
  String get formattedAccuracy {
    return '±${accuracy.toStringAsFixed(1)} meter';
  }

  // Format speed untuk ditampilkan (km/h)
  String get formattedSpeed {
    double speedKmh = speed * 3.6; // convert m/s to km/h
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }

  // Format timestamp untuk ditampilkan
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
