import 'package:flutter/material.dart'; // Untuk ThemeMode
import 'package:get/get.dart';
import '../models/car_model.dart';
import '../services/http_service.dart';
import '../services/dio_service.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';

class CarController extends GetxController {
  final httpService = HttpService();
  final dioService = DioService();
  final supabaseService = SupabaseService();
  final storageService = StorageService();

  var isLoading = false.obs;
  var carList = <CarModel>[].obs;
  var errorMessage = ''.obs;

  var httpTime = 0.obs;
  var dioTime = 0.obs;
  var supabaseTime = 0.obs;

  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  // Load theme dari shared_preferences
  Future<void> loadTheme() async {
    isDarkMode.value = await storageService.getTheme();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Toggle theme dan simpan
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await storageService.saveTheme(isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Fetch dengan HTTP (Mock Data)
  Future<void> fetchCarsWithHttp({String? make}) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Simpan ke history
    if (make != null && make.isNotEmpty) {
      await storageService.addSearchHistory(make);
    }

    final stopwatch = Stopwatch()..start();

    try {
      final cars = await httpService.getCars(make: make);
      stopwatch.stop();

      httpTime.value = stopwatch.elapsedMilliseconds;
      carList.value = cars;

      Get.snackbar(
        'HTTP Berhasil (Mock Data)',
        'Ditemukan ${cars.length} mobil dalam ${stopwatch.elapsedMilliseconds}ms',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      stopwatch.stop();
      errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Gagal mengambil data');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch dengan Dio (Mock Data)
  Future<void> fetchCarsWithDio({String? make}) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Simpan ke history
    if (make != null && make.isNotEmpty) {
      await storageService.addSearchHistory(make);
    }

    final stopwatch = Stopwatch()..start();

    try {
      final cars = await dioService.getCars(make: make);
      stopwatch.stop();

      dioTime.value = stopwatch.elapsedMilliseconds;
      carList.value = cars;

      Get.snackbar(
        'DIO Berhasil (Mock Data)',
        'Ditemukan ${cars.length} mobil dalam ${stopwatch.elapsedMilliseconds}ms',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      stopwatch.stop();
      errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Gagal mengambil data');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch dengan Supabase (Cloud Database)
  Future<void> fetchCarsWithSupabase({String? make}) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Simpan ke history
    if (make != null && make.isNotEmpty) {
      await storageService.addSearchHistory(make);
    }

    final stopwatch = Stopwatch()..start();

    try {
      final cars = await supabaseService.getCars(make: make);
      stopwatch.stop();

      supabaseTime.value = stopwatch.elapsedMilliseconds;
      carList.value = cars;

      Get.snackbar(
        'Supabase Berhasil (Cloud)',
        'Ditemukan ${cars.length} mobil dalam ${stopwatch.elapsedMilliseconds}ms',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      stopwatch.stop();
      errorMessage.value = 'Error: $e';
      Get.snackbar('Error', 'Gagal mengambil data dari cloud: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Chained Request
  Future<void> chainedRequest(String make, int days) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Simpan ke history
    await storageService.addSearchHistory(make);

    try {
      Get.snackbar('Info', 'Mencari mobil $make di cloud...');
      final cars = await supabaseService.getCars(make: make);

      if (cars.isEmpty) {
        Get.snackbar('Info', 'Mobil tidak ditemukan');
        isLoading.value = false;
        return;
      }

      carList.value = cars;

      Get.snackbar('Info', 'Mengecek ketersediaan...');
      final available =
          await supabaseService.checkAvailability(cars.first.model);

      if (available) {
        final totalPrice = cars.first.pricePerDay * days;
        Get.snackbar(
          'Tersedia!',
          '${cars.first.make} ${cars.first.model}\\n${days} hari = Rp ${totalPrice.toStringAsFixed(0)}',
          duration: Duration(seconds: 4),
        );
      } else {
        Get.snackbar('Maaf', 'Mobil sedang tidak tersedia');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Get search history dari Hive
  List<String> getSearchHistory() {
    final history = storageService.getSearchHistory();
    return history.map((h) => h.searchTerm).toList();
  }

  // Clear search history
  Future<void> clearHistory() async {
    await storageService.clearSearchHistory();
    Get.snackbar('Info', 'History pencarian dihapus');
  }
}
