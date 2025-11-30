import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';

class NetworkLocationPage extends StatelessWidget {
  final LocationController controller = Get.put(LocationController());
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Location'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => controller.clearNetworkHistory(),
            tooltip: 'Hapus History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Peta
          Expanded(
            flex: 3,
            child: Obx(() => _buildMap()),
          ),

          // Panel Info & Tombol
          Expanded(
            flex: 2,
            child: _buildInfoPanel(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await controller.fetchNetworkLocation();
          _centerMapToLocation();
        },
        backgroundColor: Colors.purple,
        icon: Obx(() => controller.isLoading.value
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.wifi, color: Colors.white)),
        label: Obx(() => Text(
              controller.isLoading.value
                  ? 'Mencari...'
                  : 'Ambil Lokasi Network',
              style: TextStyle(color: Colors.white),
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMap() {
    // Default lokasi (Indonesia - Malang)
    LatLng defaultLocation = LatLng(-7.9666, 112.6326);

    // Gunakan lokasi Network jika ada
    LatLng? currentLocation;
    if (controller.networkLocation.value != null) {
      currentLocation = LatLng(
        controller.networkLocation.value!.latitude,
        controller.networkLocation.value!.longitude,
      );
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation ?? defaultLocation,
        initialZoom: 15.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        // Layer Peta OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.aturent',
        ),

        // Layer Marker
        MarkerLayer(
          markers: [
            if (currentLocation != null)
              Marker(
                point: currentLocation,
                width: 80,
                height: 80,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Network',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.location_on,
                      color: Colors.purple,
                      size: 40,
                    ),
                  ],
                ),
              ),
          ],
        ),

        // Layer Lingkaran Akurasi
        if (currentLocation != null && controller.networkLocation.value != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: currentLocation,
                radius: controller.networkLocation.value!.accuracy,
                useRadiusInMeter: true,
                color: Colors.purple.withOpacity(0.2),
                borderColor: Colors.purple,
                borderStrokeWidth: 2,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final location = controller.networkLocation.value;

        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.purple),
                SizedBox(height: 16),
                Text('Mencari lokasi Network...'),
                Text(
                  'Menggunakan WiFi atau Cell Tower',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (location == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Tekan tombol untuk mengambil lokasi Network',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Lebih cepat dari GPS, tapi akurasi lebih rendah',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan waktu fetch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Lokasi Network',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.networkFetchTime.value} ms',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Info Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Latitude',
                      location.latitude.toStringAsFixed(6),
                      Icons.north,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoItem(
                      'Longitude',
                      location.longitude.toStringAsFixed(6),
                      Icons.east,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Akurasi',
                      location.formattedAccuracy,
                      Icons.track_changes,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoItem(
                      'Waktu',
                      location.formattedTime,
                      Icons.access_time,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Altitude',
                      '${location.altitude.toStringAsFixed(1)} m',
                      Icons.height,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoItem(
                      'Provider',
                      location.provider,
                      Icons.cell_tower,
                    ),
                  ),
                ],
              ),

              // Catatan akurasi Network
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Network location biasanya kurang akurat (50-500m) dibanding GPS',
                        style: TextStyle(
                            fontSize: 11, color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),

              // History Count
              SizedBox(height: 8),
              Text(
                'History: ${controller.networkLocationHistory.length} data tersimpan',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.purple),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _centerMapToLocation() {
    if (controller.networkLocation.value != null) {
      mapController.move(
        LatLng(
          controller.networkLocation.value!.latitude,
          controller.networkLocation.value!.longitude,
        ),
        16.0,
      );
    }
  }
}
