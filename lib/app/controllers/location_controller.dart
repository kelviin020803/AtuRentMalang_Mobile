import 'dart:async';
import 'package:get/get.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();

  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var hasPermission = false.obs;
  var isLocationEnabled = false.obs;

  // Lokasi saat ini
  var currentLocation = Rxn<LocationModel>();

  // Untuk GPS Location Page
  var gpsLocation = Rxn<LocationModel>();
  var gpsLocationHistory = <LocationModel>[].obs;
  var gpsFetchTime = 0.obs;

  // Untuk Network Location Page
  var networkLocation = Rxn<LocationModel>();
  var networkLocationHistory = <LocationModel>[].obs;
  var networkFetchTime = 0.obs;

  // Untuk Live Location Page
  var liveLocation = Rxn<LocationModel>();
  var liveLocationHistory = <LocationModel>[].obs;
  var isTracking = false.obs;
  var useGPS = true.obs; // true = GPS, false = Network
  var totalDistance = 0.0.obs;

  // Stream subscription untuk live tracking
  StreamSubscription? _liveLocationSubscription;

  @override
  void onInit() {
    super.onInit();
    checkLocationPermission();
  }

  @override
  void onClose() {
    stopLiveTracking();
    super.onClose();
  }

  // ===========================================
  // PERMISSION & SERVICE CHECK
  // ===========================================
  Future<void> checkLocationPermission() async {
    isLocationEnabled.value = await _locationService.isLocationServiceEnabled();
    hasPermission.value = await _locationService.requestPermission();
  }

  Future<void> requestPermission() async {
    hasPermission.value = await _locationService.requestPermission();
    if (!hasPermission.value) {
      Get.snackbar(
        'Izin Ditolak',
        'Aplikasi membutuhkan izin lokasi untuk berfungsi',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  // ===========================================
  // GPS LOCATION
  // ===========================================
  Future<void> fetchGPSLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    final stopwatch = Stopwatch()..start();

    try {
      // Cek permission dulu
      if (!hasPermission.value) {
        await requestPermission();
        if (!hasPermission.value) {
          isLoading.value = false;
          return;
        }
      }

      final location = await _locationService.getGPSLocation();
      stopwatch.stop();

      gpsLocation.value = location;
      gpsFetchTime.value = stopwatch.elapsedMilliseconds;

      // Simpan ke history
      gpsLocationHistory.insert(0, location);
      if (gpsLocationHistory.length > 10) {
        gpsLocationHistory.removeLast();
      }

      Get.snackbar(
        'GPS Berhasil',
        'Lokasi ditemukan dalam ${stopwatch.elapsedMilliseconds}ms\nAkurasi: ${location.formattedAccuracy}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      stopwatch.stop();
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error GPS',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================
  // NETWORK LOCATION
  // ===========================================
  Future<void> fetchNetworkLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    final stopwatch = Stopwatch()..start();

    try {
      // Cek permission dulu
      if (!hasPermission.value) {
        await requestPermission();
        if (!hasPermission.value) {
          isLoading.value = false;
          return;
        }
      }

      final location = await _locationService.getNetworkLocation();
      stopwatch.stop();

      networkLocation.value = location;
      networkFetchTime.value = stopwatch.elapsedMilliseconds;

      // Simpan ke history
      networkLocationHistory.insert(0, location);
      if (networkLocationHistory.length > 10) {
        networkLocationHistory.removeLast();
      }

      Get.snackbar(
        'Network Berhasil',
        'Lokasi ditemukan dalam ${stopwatch.elapsedMilliseconds}ms\nAkurasi: ${location.formattedAccuracy}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      stopwatch.stop();
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error Network',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================
  // LIVE LOCATION (Real-Time Tracking)
  // ===========================================
  void startLiveTracking() {
    if (isTracking.value) return;

    isTracking.value = true;
    totalDistance.value = 0.0;
    liveLocationHistory.clear();
    errorMessage.value = '';

    _liveLocationSubscription = _locationService
        .getLiveLocation(
      useGPS: useGPS.value,
      intervalMs: 2000,
      distanceFilter: 5,
    )
        .listen(
      (location) {
        // Hitung jarak jika ada lokasi sebelumnya
        if (liveLocation.value != null) {
          double distance = _locationService.calculateDistance(
            liveLocation.value!.latitude,
            liveLocation.value!.longitude,
            location.latitude,
            location.longitude,
          );
          totalDistance.value += distance;
        }

        liveLocation.value = location;

        // Simpan ke history (max 50 titik untuk polyline)
        liveLocationHistory.add(location);
        if (liveLocationHistory.length > 50) {
          liveLocationHistory.removeAt(0);
        }
      },
      onError: (e) {
        errorMessage.value = e.toString();
        stopLiveTracking();
        Get.snackbar(
          'Error Tracking',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    Get.snackbar(
      'Tracking Dimulai',
      'Mode: ${useGPS.value ? "GPS" : "Network"}',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void stopLiveTracking() {
    _liveLocationSubscription?.cancel();
    _liveLocationSubscription = null;
    isTracking.value = false;

    if (liveLocationHistory.isNotEmpty) {
      Get.snackbar(
        'Tracking Berhenti',
        'Total jarak: ${(totalDistance.value).toStringAsFixed(1)} meter',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  void toggleTrackingMode() {
    useGPS.value = !useGPS.value;
    Get.snackbar(
      'Mode Diubah',
      'Sekarang menggunakan: ${useGPS.value ? "GPS" : "Network"}',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  // ===========================================
  // CLEAR HISTORY
  // ===========================================
  void clearGPSHistory() {
    gpsLocationHistory.clear();
    gpsLocation.value = null;
    gpsFetchTime.value = 0;
  }

  void clearNetworkHistory() {
    networkLocationHistory.clear();
    networkLocation.value = null;
    networkFetchTime.value = 0;
  }

  void clearLiveHistory() {
    liveLocationHistory.clear();
    liveLocation.value = null;
    totalDistance.value = 0.0;
  }
}
