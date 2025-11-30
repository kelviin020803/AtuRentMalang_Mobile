import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/car_controller.dart';

class CarRentalPage extends StatelessWidget {
  final CarController controller = Get.put(CarController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aturent - Mod 4'),
        actions: [
          // Toggle Theme Button
          Obx(() => IconButton(
                icon: Icon(controller.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () => controller.toggleTheme(),
                tooltip: 'Toggle Theme',
              )),
          // History Button
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _showHistoryDialog(context),
            tooltip: 'Riwayat Pencarian',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Box
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Brand Mobil',
                hintText: 'Toyota, Honda, Suzuki...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Modul 4: Storage Comparison',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                        '• Mock Data: HTTP & DIO (lokal)\\n'
                        '• Cloud Data: Supabase (database online)\\n'
                        '• Search history: Hive (lokal)\\n'
                        '• Theme: SharedPreferences',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Buttons
            ElevatedButton(
              onPressed: () {
                controller.fetchCarsWithHttp(make: searchController.text);
              },
              child: Text('HTTP (Mock Local Data)'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                controller.fetchCarsWithDio(make: searchController.text);
              },
              child: Text('DIO (Mock Local Data)'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                controller.fetchCarsWithSupabase(make: searchController.text);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud),
                  SizedBox(width: 8),
                  Text('SUPABASE (Cloud Database)'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                controller.chainedRequest(searchController.text, 3);
              },
              child: Text('Chained Request (Cloud)'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 24),

            // Performance Stats
            Obx(() {
              bool hasData = controller.httpTime.value > 0 ||
                  controller.dioTime.value > 0 ||
                  controller.supabaseTime.value > 0;

              if (hasData) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('⚡ Performance Comparison',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard('HTTP\\n(Local)',
                                '${controller.httpTime.value}ms', Colors.blue),
                            _buildStatCard('DIO\\n(Local)',
                                '${controller.dioTime.value}ms', Colors.orange),
                            _buildStatCard(
                                'Supabase\\n(Cloud)',
                                '${controller.supabaseTime.value}ms',
                                Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
            SizedBox(height: 16),

            // Loading
            Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Loading...'),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Error Message
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(controller.errorMessage.value,
                        style: TextStyle(color: Colors.red.shade900)),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
            SizedBox(height: 16),

            // Car List
            Obx(() {
              if (controller.carList.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Belum ada data. Coba cari mobil!',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.carList.length,
                itemBuilder: (context, index) {
                  final car = controller.carList[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.directions_car, color: Colors.blue),
                      ),
                      title: Text('${car.make} ${car.model}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${car.year} | ${car.transmission} | ${car.fuelType}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Rp ${car.pricePerDay.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 14,
                              )),
                          Text('/hari', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    final history = controller.getSearchHistory();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.history),
            SizedBox(width: 8),
            Text('Riwayat Pencarian'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: history.isEmpty
              ? Text('Belum ada riwayat pencarian')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.search, size: 20),
                      title: Text(history[index]),
                      onTap: () {
                        searchController.text = history[index];
                        Get.back();
                      },
                    );
                  },
                ),
        ),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () {
                controller.clearHistory();
                Get.back();
              },
              child: Text('Hapus Semua'),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
