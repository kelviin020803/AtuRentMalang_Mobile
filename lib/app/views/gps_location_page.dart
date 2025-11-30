import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';

class GPSLocationPage extends StatelessWidget {
  final LocationController controller = Get.put(LocationController());
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS Location'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => controller.clearGPSHistory(),
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
          await controller.fetchGPSLocation();
          _centerMapToLocation();
        },
        backgroundColor: Colors.green,
        icon: Obx(() => controller.isLoading.value
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(Icons.gps_fixed, color: Colors.white)),
        label: Obx(() => Text(
              controller.isLoading.value ? 'Mencari...' : 'Ambil Lokasi GPS',
              style: TextStyle(color: Colors.white),
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMap() {
    // Default lokasi (Indonesia - Malang)
    LatLng defaultLocation = LatLng(-7.9666, 112.6326);

    // Gunakan lokasi GPS jika ada
    LatLng? currentLocation;
    if (controller.gpsLocation.value != null) {
      currentLocation = LatLng(
        controller.gpsLocation.value!.latitude,
        controller.gpsLocation.value!.longitude,
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
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'GPS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ],
                ),
              ),
          ],
        ),

        // Layer Lingkaran Akurasi
        if (currentLocation != null && controller.gpsLocation.value != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: currentLocation,
                radius: controller.gpsLocation.value!.accuracy,
                useRadiusInMeter: true,
                color: Colors.green.withOpacity(0.2),
                borderColor: Colors.green,
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
        final location = controller.gpsLocation.value;

        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 16),
                Text('Mencari lokasi GPS...'),
                Text(
                  'Pastikan GPS aktif dan berada di area terbuka',
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
                Icon(Icons.gps_off, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Tekan tombol untuk mengambil lokasi GPS',
                  style: TextStyle(color: Colors.grey),
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
                    'Data Lokasi GPS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.gpsFetchTime.value} ms',
                      style: TextStyle(
                        color: Colors.green.shade700,
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
                      Icons.satellite_alt,
                    ),
                  ),
                ],
              ),

              // History Count
              SizedBox(height: 12),
              Text(
                'History: ${controller.gpsLocationHistory.length} data tersimpan',
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
          Icon(icon, size: 16, color: Colors.green),
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
    if (controller.gpsLocation.value != null) {
      mapController.move(
        LatLng(
          controller.gpsLocation.value!.latitude,
          controller.gpsLocation.value!.longitude,
        ),
        16.0,
      );
    }
  }
}
