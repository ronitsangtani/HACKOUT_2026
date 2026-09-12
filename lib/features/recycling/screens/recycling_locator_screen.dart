import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../models/recycling_center.dart';

/// Recycling Locator Screen featuring an interactive OpenStreetMap view,
/// real-time center markers, pan/zoom controls, material filters, and live backend integration.
class RecyclingLocatorScreen extends ConsumerStatefulWidget {
  const RecyclingLocatorScreen({super.key});

  @override
  ConsumerState<RecyclingLocatorScreen> createState() => _RecyclingLocatorScreenState();
}

class _RecyclingLocatorScreenState extends ConsumerState<RecyclingLocatorScreen> {
  final MapController _mapController = MapController();
  String _searchQuery = '';
  String? _selectedMaterial;
  RecyclingCenter? _selectedCenter;

  // Default coordinate center (Bengaluru tech / circular hub)
  static const LatLng _defaultCenter = LatLng(12.9716, 77.5946);

  bool _isValidCoord(double lat, double lng) {
    return !lat.isNaN && !lng.isNaN && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom + 1).clamp(5.0, 18.0));
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom - 1).clamp(5.0, 18.0));
  }

  void _resetMap() {
    setState(() => _selectedCenter = null);
    _mapController.move(_defaultCenter, 12.0);
  }

  @override
  Widget build(BuildContext context) {
    final centersAsync = ref.watch(recyclingCentersProvider(_selectedMaterial));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling & Circular Hubs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Centers',
            onPressed: () => ref.refresh(recyclingCentersProvider(_selectedMaterial)),
          ),
        ],
      ),
      body: SafeArea(
        child: centersAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text('Loading circular drop-off hubs...', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text('Could Not Load Centers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(err.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(recyclingCentersProvider(_selectedMaterial)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (centers) {
            // Apply search filter
            final filteredCenters = centers.where((center) {
              final matchesSearch = center.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  center.address.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesSearch;
            }).toList();

            final validMarkers = filteredCenters.where((c) => _isValidCoord(c.latitude, c.longitude)).toList();

            return Column(
              children: [
                // Search Bar & Filter Chips
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search centers by name or locality...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All Materials', null),
                            const SizedBox(width: 8),
                            _buildFilterChip('E-Waste', 'E-Waste'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Plastic', 'Plastic'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Clothes', 'Clothes'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Paper', 'Paper'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Interactive Map Container
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: _defaultCenter,
                          initialZoom: 12.0,
                          minZoom: 4.0,
                          maxZoom: 18.0,
                          interactionOptions: InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.hackout.carbonloopapp',
                          ),
                          MarkerLayer(
                            markers: validMarkers.map((center) {
                              final isSelected = _selectedCenter?.id == center.id;
                              return Marker(
                                point: LatLng(center.latitude, center.longitude),
                                width: isSelected ? 48 : 38,
                                height: isSelected ? 48 : 38,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedCenter = center);
                                    _mapController.move(LatLng(center.latitude, center.longitude), 14.0);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.amber.shade700 : AppTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.recycling,
                                      color: Colors.white,
                                      size: isSelected ? 24 : 18,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // Zoom & Reset Map Controls
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Column(
                          children: [
                            _buildMapControlBtn(Icons.add, _zoomIn, 'Zoom In'),
                            const SizedBox(height: 6),
                            _buildMapControlBtn(Icons.remove, _zoomOut, 'Zoom Out'),
                            const SizedBox(height: 6),
                            _buildMapControlBtn(Icons.my_location, _resetMap, 'Reset Center'),
                          ],
                        ),
                      ),

                      // Selected Center Card Overlay
                      if (_selectedCenter != null)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.lightGreen,
                                    child: const Icon(Icons.location_on, color: AppTheme.primaryGreen),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _selectedCenter!.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _selectedCenter!.address,
                                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${_selectedCenter!.distance} • ${_selectedCenter!.operatingHours}',
                                          style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () => setState(() => _selectedCenter = null),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Centers List Section
                Expanded(
                  flex: 2,
                  child: RefreshIndicator(
                    color: AppTheme.primaryGreen,
                    onRefresh: () async {
                      await ref.refresh(recyclingCentersProvider(_selectedMaterial).future);
                    },
                    child: filteredCenters.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 30),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.location_off_outlined, size: 48, color: Colors.grey),
                                    SizedBox(height: 10),
                                    Text('No recycling centers matched your filter.', style: TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: filteredCenters.length,
                            itemBuilder: (context, index) {
                              final center = filteredCenters[index];
                              final isSelected = _selectedCenter?.id == center.id;
                              return _buildCenterCard(center, isSelected);
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapControlBtn(IconData icon, VoidCallback onPressed, String tooltip) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AppTheme.darkText),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildFilterChip(String label, String? material) {
    final isSelected = _selectedMaterial == material;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.darkText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (_) {
        setState(() {
          _selectedMaterial = material;
          _selectedCenter = null;
        });
      },
    );
  }

  Widget _buildCenterCard(RecyclingCenter center, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isSelected ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? const BorderSide(color: AppTheme.primaryGreen, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _selectedCenter = center);
          if (_isValidCoord(center.latitude, center.longitude)) {
            _mapController.move(LatLng(center.latitude, center.longitude), 14.5);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      center.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected ? AppTheme.primaryGreen : AppTheme.darkText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      center.distance,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(center.address, style: const TextStyle(fontSize: 11, color: Colors.black54), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(center.operatingHours, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: center.acceptedMaterials.map((mat) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(mat, style: const TextStyle(fontSize: 9, color: Colors.black87)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
