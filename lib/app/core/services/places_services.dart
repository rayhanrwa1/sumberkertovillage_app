import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  // Get API key from .env file
  static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  /// Search places using Google Places Autocomplete API
  ///
  /// [input] - The text string on which to search
  /// [language] - Language code (default: 'id' for Indonesian)
  /// [components] - Restrict results to specific country (default: 'country:id' for Indonesia)
  static Future<List<PlaceSuggestion>> searchPlaces(
    String input, {
    String language = 'id',
    String components = 'country:id',
  }) async {
    if (input.isEmpty) {
      return [];
    }

    try {
      print('PlacesService: Searching for "$input"');
      print('PlacesService: API Key length: ${_apiKey.length}');

      final url = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'input': input,
          'key': _apiKey,
          'language': language,
          'components': components,
        },
      );

      print(
        'PlacesService: Request URL: ${url.toString().replaceAll(_apiKey, 'HIDDEN_KEY')}',
      );

      final response = await http.get(url);

      print('PlacesService: Response status: ${response.statusCode}');
      print('PlacesService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          print('PlacesService: Found ${predictions.length} predictions');
          return predictions
              .map((prediction) => PlaceSuggestion.fromJson(prediction))
              .toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('PlacesService: Zero results');
          return [];
        } else {
          print('PlacesService: API error: ${data['status']}');
          if (data['error_message'] != null) {
            print('PlacesService: Error message: ${data['error_message']}');
          }
          return [];
        }
      } else {
        print('PlacesService: HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('PlacesService: Exception: $e');
      print('PlacesService: Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get place details by place_id
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final url =
          Uri.parse(
            'https://maps.googleapis.com/maps/api/place/details/json',
          ).replace(
            queryParameters: {
              'place_id': placeId,
              'key': _apiKey,
              'language': 'id',
              'fields': 'name,formatted_address,geometry',
            },
          );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }
}

/// Place suggestion model
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String? secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'];
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
      mainText: structuredFormatting['main_text'],
      secondaryText: structuredFormatting['secondary_text'],
    );
  }
}

/// Place details model
class PlaceDetails {
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final location = geometry['location'];

    return PlaceDetails(
      name: json['name'],
      formattedAddress: json['formatted_address'],
      latitude: location['lat'],
      longitude: location['lng'],
    );
  }
}
