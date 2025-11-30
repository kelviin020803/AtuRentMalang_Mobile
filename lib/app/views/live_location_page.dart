import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';

class LiveLocationPage extends StatelessWidget {
  final LocationController controller = Get.put(LocationController());
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          // Toggle GPS/Network
          Obx(() => IconButton(
                icon: Icon(
                  controller.useGPS.value ? Icons.gps_fixed : Icons.wifi,
                ),
                onPressed: () {
                  if (!controller.isTracking.value) {
                    controller.toggleTrackingMode();
                  } else {
                    Get.snackbar(
                      'Info',
                      'Hentikan tracking dulu untuk mengubah mode',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                tooltip:
                    controller.useGPS.value ? 'Mode: GPS' : 'Mode: Network',
              )),
          // Clear History
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              if (!controller.isTracking.value) {
                controller.clearLiveHistory();
              }
            },
            tooltip: 'Hapus History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode Indicator
          Obx(() => Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                color: controller.useGPS.value
                    ? Colors.green.shade100
                    : Colors.purple.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.useGPS.value ? Icons.gps_fixed : Icons.wifi,
                      size: 16,
                      color: controller.useGPS.value
                          ? Colors.green.shade700
                          : Colors.purple.shade700,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mode: ${controller.useGPS.value ? "GPS (Akurat)" : "Network (Cepat)"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: controller.useGPS.value
                            ? Colors.green.shade700
                            : Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              )),

          // Peta
          Expanded(
            flex: 3,
            child: Obx(() => _buildMap()),
          ),

          // Panel Info
          Expanded(
            flex: 2,
            child: _buildInfoPanel(),
          ),
        ],
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: () {
              if (controller.isTracking.value) {
                controller.stopLiveTracking();
              } else {
                controller.startLiveTracking();
              }
            },
            backgroundColor:
                controller.isTracking.value ? Colors.grey : Colors.red,
            icon: Icon(
              controller.isTracking.value ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
            label: Text(
              controller.isTracking.value ? 'Stop Tracking' : 'Start Tracking',
              style: TextStyle(color: Colors.white),
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMap() {
    // Default lokasi (Indonesia - Malang)
    LatLng defaultLocation = LatLng(-7.9666, 112.6326);

    // Gunakan lokasi Live jika ada
    LatLng? currentLocation;
    if (controller.liveLocation.value != null) {
      currentLocation = LatLng(
        controller.liveLocation.value!.latitude,
        controller.liveLocation.value!.longitude,
      );
    }

    // Buat list titik untuk polyline dari history
    List<LatLng> polylinePoints = controller.liveLocationHistory
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation ?? defaultLocation,
        initialZoom: 16.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        onPositionChanged: (position, hasGesture) {
          // Auto center saat tracking (jika tidak di-drag manual)
          if (controller.isTracking.value &&
              !hasGesture &&
              currentLocation != null) {
            // Biarkan user scroll manual
          }
        },
      ),
      children: [
        // Layer Peta OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.aturent',
        ),

        // Layer Polyline (Jejak Perjalanan)
        if (polylinePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                color: Colors.red,
                strokeWidth: 4.0,
              ),
            ],
          ),

        // Layer Marker Titik Awal (jika ada history)
        if (polylinePoints.isNotEmpty)
          MarkerLayer(
            markers: [
              // Marker titik awal (hijau)
              Marker(
                point: polylinePoints.first,
                width: 40,
                height: 40,
                child: Icon(
                  Icons.trip_origin,
                  color: Colors.green,
                  size: 24,
                ),
              ),
            ],
          ),

        // Layer Marker Lokasi Saat Ini
        MarkerLayer(
          markers: [
            if (currentLocation != null)
              Marker(
                point: currentLocation,
                width: 100,
                height: 100,
                child: Column(
                  children: [
                    // Label
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Live',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Animated Icon
                    controller.isTracking.value
                        ? _buildPulsingMarker()
                        : Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                  ],
                ),
              ),
          ],
        ),

        // Layer Lingkaran Akurasi
        if (currentLocation != null && controller.liveLocation.value != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: currentLocation,
                radius: controller.liveLocation.value!.accuracy,
                useRadiusInMeter: true,
                color: Colors.red.withOpacity(0.15),
                borderColor: Colors.red,
                borderStrokeWidth: 2,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPulsingMarker() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: Duration(milliseconds: 800),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Icon(
            Icons.my_location,
            color: Colors.red,
            size: 36,
          ),
        );
      },
      onEnd: () {},
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
        final location = controller.liveLocation.value;
        final isTracking = controller.isTracking.value;

        if (!isTracking && location == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_walk, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Tekan tombol Start untuk mulai tracking',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Ubah mode GPS/Network di tombol atas',
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
              // Header dengan status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isTracking ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        isTracking ? 'Tracking Aktif' : 'Tracking Berhenti',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.liveLocationHistory.length} titik',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Info Grid
              if (location != null) ...[
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
                        'Kecepatan',
                        location.formattedSpeed,
                        Icons.speed,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Total Jarak',
                        '${controller.totalDistance.value.toStringAsFixed(1)} m',
                        Icons.straighten,
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
              ],

              // Tombol Center ke lokasi
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _centerMapToLocation(),
                  icon: Icon(Icons.my_location),
                  label: Text('Pusatkan Peta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
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
          Icon(icon, size: 16, color: Colors.red),
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
    if (controller.liveLocation.value != null) {
      mapController.move(
        LatLng(
          controller.liveLocation.value!.latitude,
          controller.liveLocation.value!.longitude,
        ),
        17.0,
      );
    }
  }
}
