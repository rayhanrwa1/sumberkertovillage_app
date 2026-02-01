import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

class DirectionsService {
  static const String apiKey = 'AIzaSyCkymj5pLqGSbraogMIjOmgXMuqR583uUs';
  
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${start.latitude},${start.longitude}'
      '&destination=${end.latitude},${end.longitude}'
      '&mode=driving'
      '&key=$apiKey',
    );

    final res = await http.get(uri);
    final data = jsonDecode(res.body);

    final encoded = data['routes'][0]['overview_polyline']['points'];

    final decoded = decodePolyline(encoded);

    return decoded
        .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
        .toList();
  }
}
