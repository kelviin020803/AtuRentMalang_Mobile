import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/car_controller.dart';
import 'car_rental_page.dart';
import 'gps_location_page.dart';
import 'network_location_page.dart';
import 'live_location_page.dart';

class HomePage extends StatelessWidget {
  final CarController carController = Get.put(CarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aturent - Menu Utama'),
        centerTitle: true,
        actions: [
          // Toggle Theme Button
          Obx(() => IconButton(
                icon: Icon(carController.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () => carController.toggleTheme(),
                tooltip: 'Toggle Theme',
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.directions_car, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Selamat Datang di Aturent',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Aplikasi Rental Mobil dengan Fitur Lokasi',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Section: Modul 4 - Car Rental
            _buildSectionTitle('Modul 4 - Data & Storage'),
            SizedBox(height: 8),
            _buildMenuCard(
              icon: Icons.car_rental,
              title: 'Car Rental',
              subtitle: 'HTTP, DIO, Supabase, Hive, SharedPreferences',
              color: Colors.orange,
              onTap: () => Get.to(() => CarRentalPage()),
            ),
            SizedBox(height: 24),

            // Section: Modul 5 - Location
            _buildSectionTitle('Modul 5 - Location Aware'),
            SizedBox(height: 8),
            _buildMenuCard(
              icon: Icons.gps_fixed,
              title: 'GPS Location',
              subtitle: 'Lokasi akurat via satelit GPS',
              color: Colors.green,
              onTap: () => Get.to(() => GPSLocationPage()),
            ),
            SizedBox(height: 12),
            _buildMenuCard(
              icon: Icons.wifi,
              title: 'Network Location',
              subtitle: 'Lokasi cepat via WiFi/Cell Tower',
              color: Colors.purple,
              onTap: () => Get.to(() => NetworkLocationPage()),
            ),
            SizedBox(height: 12),
            _buildMenuCard(
              icon: Icons.my_location,
              title: 'Live Location',
              subtitle: 'Tracking real-time dengan peta',
              color: Colors.red,
              onTap: () => Get.to(() => LiveLocationPage()),
            ),
            SizedBox(height: 24),

            // Info Card
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Informasi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• GPS: Akurasi tinggi, butuh waktu lebih lama\n'
                      '• Network: Lebih cepat, akurasi lebih rendah\n'
                      '• Live: Tracking pergerakan real-time',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          color: Colors.blue,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
