import '../models/car_model.dart';

class HttpService {
  final List<Map<String, dynamic>> _mockCars = [
    {
      'model': 'Avanza',
      'make': 'Toyota',
      'year': 2023,
      'fuelType': 'Bensin',
      'transmission': 'Manual',
      'pricePerDay': 300000,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'model': 'Innova Reborn',
      'make': 'Toyota',
      'year': 2022,
      'fuelType': 'Diesel',
      'transmission': 'Automatic',
      'pricePerDay': 450000,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'model': 'Brio',
      'make': 'Honda',
      'year': 2023,
      'fuelType': 'Bensin',
      'transmission': 'Manual',
      'pricePerDay': 250000,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'model': 'CR-V',
      'make': 'Honda',
      'year': 2023,
      'fuelType': 'Bensin',
      'transmission': 'Automatic',
      'pricePerDay': 600000,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'model': 'Ertiga',
      'make': 'Suzuki',
      'year': 2022,
      'fuelType': 'Bensin',
      'transmission': 'Manual',
      'pricePerDay': 280000,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'model': 'Xpander',
      'make': 'Mitsubishi',
      'year': 2023,
      'fuelType': 'Bensin',
      'transmission': 'Automatic',
      'pricePerDay': 400000,
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ];

  Future<List<CarModel>> getCars({String? make}) async {
    await Future.delayed(Duration(milliseconds: 800));

    List<Map<String, dynamic>> filteredCars = _mockCars;

    if (make != null && make.isNotEmpty) {
      filteredCars = _mockCars
          .where(
            (car) => car['make'].toString().toLowerCase().contains(
                  make.toLowerCase(),
                ),
          )
          .toList();
    }

    return filteredCars.map((json) => CarModel.fromJson(json)).toList();
  }

  Future<bool> checkAvailability(String carModel) async {
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }
}
