import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service untuk convert GPS coordinates ke nama lokasi
/// Menggunakan Nominatim (OpenStreetMap)
///
/// NOTE:
/// - Gratis
/// - WAJIB pakai User-Agent
/// - Ada rate limit → jangan spam
class GeocodingService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Reverse geocoding (lat, lon → kota, provinsi)
  static Future<String?> reverseGeocodeNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse(
        '$_nominatimBaseUrl/reverse'
        '?format=json'
        '&lat=$latitude'
        '&lon=$longitude'
        '&zoom=10'
        '&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'SumberkertoSmartVillage/1.0'},
      );

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final address = data['address'] as Map<String, dynamic>?;

      if (address == null) return null;

      final city =
          address['city'] ??
          address['town'] ??
          address['village'] ??
          address['municipality'] ??
          address['county'];

      final province = address['state'] ?? address['province'];

      if (city != null && province != null) {
        return '$city, $province';
      }

      return city;
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }

  static Future<String?> getLocationName(
    double latitude,
    double longitude,
  ) async {
    return reverseGeocodeNominatim(latitude, longitude);
  }

  /// Parse GPS coordinate dari EXIF
  /// Format: [deg, min, sec]
  static double? parseGpsCoordinate(dynamic gpsData) {
    try {
      if (gpsData is List && gpsData.length >= 3) {
        final deg = _parseRational(gpsData[0]);
        final min = _parseRational(gpsData[1]);
        final sec = _parseRational(gpsData[2]);

        if (deg == null || min == null || sec == null) return null;
        return deg + (min / 60) + (sec / 3600);
      }

      if (gpsData is double) return gpsData;
      if (gpsData is int) return gpsData.toDouble();

      return null;
    } catch (e) {
      print('GPS parse error: $e');
      return null;
    }
  }

  static double? _parseRational(dynamic value) {
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();

      if (value is List && value.length == 2) {
        final nume = value[0] as num;
        final deno = value[1] as num;
        if (deno == 0) return null;
        return nume / deno;
      }

      if (value is String && value.contains('/')) {
        final parts = value.split('/');
        final nume = double.parse(parts[0]);
        final deno = double.parse(parts[1]);
        if (deno == 0) return null;
        return nume / deno;
      }

      return double.tryParse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static bool isValidCoordinate(double? lat, double? lon) {
    if (lat == null || lon == null) return false;
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }
}

/// ✅ EXTENSION AMAN (TANPA IfdTag, TANPA ERROR)
extension ExifGpsSafeExtension on Map<dynamic, dynamic> {
  (double?, double?) get gpsCoordinates {
    final latTag = this['GPS GPSLatitude'];
    final lonTag = this['GPS GPSLongitude'];
    final latRef = this['GPS GPSLatitudeRef'];
    final lonRef = this['GPS GPSLongitudeRef'];

    if (latTag == null || lonTag == null) return (null, null);

    final latValues = latTag.values ?? latTag;
    final lonValues = lonTag.values ?? lonTag;

    double? lat = GeocodingService.parseGpsCoordinate(latValues);
    double? lon = GeocodingService.parseGpsCoordinate(lonValues);

    if (lat == null || lon == null) return (null, null);

    final latRefValue = latRef?.printable ?? latRef;
    final lonRefValue = lonRef?.printable ?? lonRef;

    if (latRefValue == 'S') lat = -lat;
    if (lonRefValue == 'W') lon = -lon;

    return (lat, lon);
  }
}
