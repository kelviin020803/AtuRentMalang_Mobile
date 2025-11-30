import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService {
  // Cek apakah layanan lokasi aktif
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Minta izin lokasi
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Cek status permission saat ini
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Buka pengaturan lokasi device
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Buka pengaturan aplikasi (untuk permission)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // ===========================================
  // GPS LOCATION (Akurasi Tinggi)
  // ===========================================
  Future<LocationModel> getGPSLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, // Akurasi terbaik (GPS)
          timeLimit: Duration(seconds: 30),
        ),
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: position.timestamp,
        provider: 'GPS',
      );
    } catch (e) {
      throw Exception('Gagal mendapatkan lokasi GPS: $e');
    }
  }

  // ===========================================
  // NETWORK LOCATION (Akurasi Rendah, Lebih Cepat)
  // ===========================================
  Future<LocationModel> getNetworkLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Akurasi rendah (Network/WiFi)
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: position.timestamp,
        provider: 'Network',
      );
    } catch (e) {
      throw Exception('Gagal mendapatkan lokasi Network: $e');
    }
  }

  // ===========================================
  // LIVE LOCATION (Stream Real-Time)
  // ===========================================
  Stream<LocationModel> getLiveLocation({
    bool useGPS = true,
    int intervalMs = 1000,
    int distanceFilter = 5,
  }) {
    late LocationSettings locationSettings;

    if (useGPS) {
      // Mode GPS - Akurasi tinggi
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
        intervalDuration: Duration(milliseconds: intervalMs),
        forceLocationManager: false,
      );
    } else {
      // Mode Network - Akurasi rendah, hemat baterai
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: distanceFilter,
        intervalDuration: Duration(milliseconds: intervalMs),
        forceLocationManager: true, // Paksa pakai Network
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((Position position) {
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: position.timestamp,
        provider: useGPS ? 'GPS' : 'Network',
      );
    });
  }

  // ===========================================
  // HITUNG JARAK ANTARA 2 TITIK (dalam meter)
  // ===========================================
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }
}
