import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sumberkerto_smart_village/app/core/services/location_service.dart';

class LocationPickerSheet extends StatefulWidget {
  final Function(String location) onLocationSelected;

  const LocationPickerSheet({Key? key, required this.onLocationSelected})
    : super(key: key);

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _nearbyPlaces = [];
  final List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() => _isLoading = true);

    try {
      _currentPosition = await LocationService.getCurrentLocation();

      if (_currentPosition != null) {
        final places = await LocationService.getNearbyPlaces(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          radius: 5000,
        );

        if (mounted) {
          setState(() {
            _nearbyPlaces.clear();
            _nearbyPlaces.addAll(places);
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading nearby places: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() => _isSearching = true);
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      final places = await LocationService.searchPlaces(
        query,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        radius: 50000,
      );

      if (mounted && _searchController.text.trim() == query) {
        setState(() {
          _searchResults.clear();
          _searchResults.addAll(places);
        });
      }
    } catch (e) {
      print('Error searching places: $e');
    }
  }

  String _formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) return '';

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  double? _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.navigation, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Lokasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Color(0xFF0A84FF), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Pilih lokasi untuk ditandai',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Orang yang melihat konten ini dapat melihat lokasi yang Anda tandai dan melihatnya di peta.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari lokasi',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0A84FF)),
                  )
                : _buildLocationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList() {
    final locations = _isSearching ? _searchResults : _nearbyPlaces;

    if (locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _isSearching
                  ? 'Tidak ada hasil ditemukan'
                  : 'Tidak ada lokasi terdekat',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        final name = location['name'] ?? 'Tidak diketahui';
        final vicinity =
            location['vicinity'] ?? location['formatted_address'] ?? '';
        final lat = location['lat'] ?? 0.0;
        final lng = location['lng'] ?? 0.0;

        final distance = _calculateDistance(lat, lng);
        final distanceText = _formatDistance(distance);

        return InkWell(
          onTap: () {
            final fullLocation = vicinity.isNotEmpty
                ? '$name, $vicinity'
                : name;
            widget.onLocationSelected(fullLocation);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (vicinity.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          vicinity,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (distanceText.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text(
                    distanceText,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
