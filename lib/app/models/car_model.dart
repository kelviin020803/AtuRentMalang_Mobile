class CarModel {
  final String model;
  final String make;
  final int year;
  final String fuelType;
  final String transmission;
  final double pricePerDay;
  final String imageUrl;

  CarModel({
    required this.model,
    required this.make,
    required this.year,
    required this.fuelType,
    required this.transmission,
    required this.pricePerDay,
    required this.imageUrl,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      model: json['model'],
      make: json['make'],
      year: json['year'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
      pricePerDay: json['pricePerDay'].toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'make': make,
      'year': year,
      'fuelType': fuelType,
      'transmission': transmission,
      'pricePerDay': pricePerDay,
      'imageUrl': imageUrl,
    };
  }
}
