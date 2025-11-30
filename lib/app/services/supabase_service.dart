import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car_model.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase belum diinisialisasi');
    }
    return _client!;
  }

  // Get all cars dari Supabase
  Future<List<CarModel>> getCars({String? make}) async {
    try {
      var query = client.from('cars').select();

      if (make != null && make.isNotEmpty) {
        query = query.ilike('make', '%$make%');
      }

      final response = await query;

      return (response as List).map((json) {
        return CarModel(
          model: json['model'],
          make: json['make'],
          year: json['year'],
          fuelType: json['fuel_type'],
          transmission: json['transmission'],
          pricePerDay: (json['price_per_day'] as num).toDouble(),
          imageUrl: json['image_url'] ?? 'https://via.placeholder.com/150',
        );
      }).toList();
    } catch (e) {
      print('Error fetching from Supabase: $e');
      throw Exception('Gagal mengambil data dari cloud: $e');
    }
  }

  // Check availability
  Future<bool> checkAvailability(String model) async {
    try {
      final response = await client
          .from('cars')
          .select('available')
          .eq('model', model)
          .single();

      return response['available'] ?? false;
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }

  // Update availability (untuk booking)
  Future<void> updateAvailability(String model, bool available) async {
    try {
      await client
          .from('cars')
          .update({'available': available}).eq('model', model);
    } catch (e) {
      print('Error updating availability: $e');
      throw Exception('Gagal update availability');
    }
  }
}
