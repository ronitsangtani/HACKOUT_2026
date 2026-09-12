import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../../../core/widgets/primary_game_button.dart';
import '../models/recycling_center.dart';

/// Duolingo-styled Eco Map Screen featuring interactive OpenStreetMap,
/// playful emoji filter chips, tactile floating map controls, and selected hub card.
class RecyclingLocatorScreen extends ConsumerStatefulWidget {
  const RecyclingLocatorScreen({super.key});

  @override
  ConsumerState<RecyclingLocatorScreen> createState() => _RecyclingLocatorScreenState();
}

class _RecyclingLocatorScreenState extends ConsumerState<RecyclingLocatorScreen> {
  final MapController _mapController = MapController();
  String? _selectedFilter; // null = all, 'recycling', 'transport', 'ev', 'stores'
  RecyclingCenter? _selectedCenter;

  static const LatLng _defaultCenter = LatLng(12.9716, 77.5946);

  final List<Map<String, String>> _filterOptions = const [
    {'key': 'all', 'label': 'All Hubs', 'emoji': '🌍'},
    {'key': 'recycling', 'label': 'Recycling', 'emoji': '♻️'},
    {'key': 'transport', 'label': 'Transport', 'emoji': '🚌'},
    {'key': 'ev', 'label': 'EV Hubs', 'emoji': '🔋'},
    {'key': 'stores', 'label': 'Eco Stores', 'emoji': '🌱'},
  ];

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom + 1).clamp(5.0, 18.0));
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (currentZoom - 1).clamp(5.0, 18.0));
  }

  void _recenter() {
    setState(() => _selectedCenter = null);
    _mapController.move(_defaultCenter, 12.5);
  }

  @override
  Widget build(BuildContext context) {
    final centersAsync = ref.watch(recyclingCentersProvider(_selectedFilter == 'all' ? null : _selectedFilter));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ECO MAP',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.duoSubtext),
            tooltip: 'Refresh Hubs',
            onPressed: () => ref.invalidate(recyclingCentersProvider(_selectedFilter == 'all' ? null : _selectedFilter)),
          ),
        ],
      ),
      body: SafeArea(
        child: centersAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.duoGreen),
                SizedBox(height: 16),
                Text('Loading eco locations...', style: TextStyle(color: AppTheme.duoSubtext, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🗺️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Could not load map hubs: $err', style: const TextStyle(color: AppTheme.duoSubtext)),
                const SizedBox(height: 16),
                PrimaryGameButton(
                  text: 'RETRY',
                  isFullWidth: false,
                  color: GameButtonColor.green,
                  onPressed: () => ref.invalidate(recyclingCentersProvider(_selectedFilter == 'all' ? null : _selectedFilter)),
                ),
              ],
            ),
          ),
          data: (centers) {
            final validCenters = centers.isNotEmpty ? centers : RecyclingCenter.mockCenters;

            return Stack(
              children: [
                // 1. Interactive OpenStreetMap
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 12.5,
                    minZoom: 4.0,
                    maxZoom: 18.0,
                    interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hackout.carbonloopapp',
                    ),
                    MarkerLayer(
                      markers: validCenters.map((c) {
                        final isSelected = _selectedCenter?.id == c.id;

                        return Marker(
                          point: LatLng(c.latitude, c.longitude),
                          width: isSelected ? 54 : 44,
                          height: isSelected ? 54 : 44,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedCenter = c);
                              _mapController.move(LatLng(c.latitude, c.longitude), 14.0);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.duoGreen : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.duoGreenDark : AppTheme.duoGray,
                                  width: 2.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 4),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                c.acceptedMaterials.contains('E-Waste') ? '🔋' : '♻️',
                                style: TextStyle(fontSize: isSelected ? 26 : 20),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // 2. Floating Filter Pills (Duolingo Style)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterOptions.map((f) {
                        final isSelected = (_selectedFilter ?? 'all') == f['key'];

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = f['key'];
                                _selectedCenter = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.duoGreen : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppTheme.duoGreenDark : AppTheme.duoGray,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 3),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(f['emoji']!, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    f['label']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      color: isSelected ? Colors.white : AppTheme.duoText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // 3. Floating 3D Map Zoom & Recenter Controls
                Positioned(
                  right: 14,
                  bottom: _selectedCenter != null ? 220 : 20,
                  child: Column(
                    children: [
                      _buildFloatingButton(
                        icon: Icons.add_rounded,
                        onTap: _zoomIn,
                      ),
                      const SizedBox(height: 8),
                      _buildFloatingButton(
                        icon: Icons.remove_rounded,
                        onTap: _zoomOut,
                      ),
                      const SizedBox(height: 8),
                      _buildFloatingButton(
                        icon: Icons.my_location_rounded,
                        onTap: _recenter,
                      ),
                    ],
                  ),
                ),

                // 4. Selected Facility Bottom Sliding Card
                if (_selectedCenter != null)
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.duoGray, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, offset: Offset(0, 6), blurRadius: 10),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.duoGreenLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Text('📍', style: TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedCenter!.name,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.duoText),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedCenter!.address,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.duoSubtext),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppTheme.duoSubtext),
                                onPressed: () => setState(() => _selectedCenter = null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.duoYellowLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedCenter!.distance,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.duoYellowDark),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${_selectedCenter!.contact}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.duoSubtext, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          PrimaryGameButton(
                            text: 'GET DIRECTIONS',
                            color: GameButtonColor.green,
                            height: 48,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening navigation to ${_selectedCenter!.name}'),
                                  backgroundColor: AppTheme.duoGreen,
                                ),
                              );
                            },
                          ),
                        ],
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

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.duoGray, width: 2),
          boxShadow: const [
            BoxShadow(color: AppTheme.duoGray, offset: Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: AppTheme.duoText, size: 22),
      ),
    );
  }
}
