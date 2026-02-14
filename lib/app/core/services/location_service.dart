import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static String get _googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Check dan request location permission
  static Future<bool> checkAndRequestPermission() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Open app settings
      await openAppSettings();
      return false;
    }

    return true;
  }

  /// Get current device location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Reverse geocoding menggunakan Google Maps API
  /// Mengembalikan format: "Nama Tempat, Kota, Provinsi"
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude, {
    bool useGoogleMapsApi = true,
  }) async {
    try {
      if (useGoogleMapsApi) {
        // Gunakan Google Maps Geocoding API untuk hasil lebih akurat
        return await _getAddressFromGoogleMaps(latitude, longitude);
      } else {
        // Fallback ke geocoding package (gratis tapi kurang akurat)
        return await _getAddressFromGeocodingPackage(latitude, longitude);
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Get address menggunakan Google Maps Geocoding API
  static Future<String?> _getAddressFromGoogleMaps(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_googleMapsApiKey&language=id',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final results = data['results'] as List;

          // Cari hasil yang paling spesifik (biasanya index 0)
          final firstResult = results[0];
          final addressComponents = firstResult['address_components'] as List;

          String? premise; // Nama tempat spesifik (e.g., "Starbucks")
          String? route; // Nama jalan
          String? sublocality; // Kelurahan/kecamatan
          String? locality; // Kota
          String? adminArea; // Provinsi

          // Parse address components
          for (var component in addressComponents) {
            final types = component['types'] as List;

            if (types.contains('premise') || types.contains('establishment')) {
              premise = component['long_name'];
            } else if (types.contains('route')) {
              route = component['long_name'];
            } else if (types.contains('sublocality') ||
                types.contains('sublocality_level_1')) {
              sublocality = component['long_name'];
            } else if (types.contains('locality') ||
                types.contains('administrative_area_level_2')) {
              locality = component['long_name'];
            } else if (types.contains('administrative_area_level_1')) {
              adminArea = component['long_name'];
            }
          }

          // Format seperti Instagram: "Nama Tempat, Kota" atau "Kecamatan, Kota"
          final List<String> addressParts = [];

          if (premise != null && premise.isNotEmpty) {
            addressParts.add(premise);
          } else if (route != null && route.isNotEmpty) {
            addressParts.add(route);
          } else if (sublocality != null && sublocality.isNotEmpty) {
            addressParts.add(sublocality);
          }

          if (locality != null && locality.isNotEmpty) {
            addressParts.add(locality);
          } else if (adminArea != null && adminArea.isNotEmpty) {
            addressParts.add(adminArea);
          }

          if (addressParts.isNotEmpty) {
            return addressParts.join(', ');
          }

          // Fallback: gunakan formatted_address
          return firstResult['formatted_address'];
        }
      }

      return null;
    } catch (e) {
      print('Error Google Maps API: $e');
      return null;
    }
  }

  /// Fallback: menggunakan geocoding package (gratis, tanpa API key)
  static Future<String?> _getAddressFromGeocodingPackage(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Format: "Nama Tempat, Kota" atau "Kecamatan, Kota"
        final List<String> addressParts = [];

        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        } else if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }

        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        }
      }

      return null;
    } catch (e) {
      print('Error geocoding package: $e');
      return null;
    }
  }

  /// Get nearby places menggunakan Google Places API (opsional untuk fitur pencarian)
  static Future<List<Map<String, dynamic>>> getNearbyPlaces(
    double latitude,
    double longitude, {
    int radius = 1000, // meter
    String? type, // e.g., 'restaurant', 'cafe', 'store'
  }) async {
    try {
      final typeParam = type != null ? '&type=$type' : '';
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius$typeParam&key=$_googleMapsApiKey&language=id',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;

          return results.map((place) {
            return {
              'name': place['name'],
              'vicinity': place['vicinity'],
              'lat': place['geometry']['location']['lat'],
              'lng': place['geometry']['location']['lng'],
              'place_id': place['place_id'],
            };
          }).toList();
        }
      }

      return [];
    } catch (e) {
      print('Error getting nearby places: $e');
      return [];
    }
  }

  /// Search places by query
  static Future<List<Map<String, dynamic>>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    int radius = 5000,
  }) async {
    try {
      String locationParam = '';
      if (latitude != null && longitude != null) {
        locationParam = '&location=$latitude,$longitude&radius=$radius';
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query$locationParam&key=$_googleMapsApiKey&language=id',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;

          return results.map((place) {
            return {
              'name': place['name'],
              'formatted_address': place['formatted_address'],
              'lat': place['geometry']['location']['lat'],
              'lng': place['geometry']['location']['lng'],
              'place_id': place['place_id'],
            };
          }).toList();
        }
      }

      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
}
