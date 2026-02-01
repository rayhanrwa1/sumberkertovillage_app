import 'package:google_maps_flutter/google_maps_flutter.dart';

class JalanRusakModel {
  final String id;
  final String nama;
  final String deskripsi;
  final List<LatLng> points;

  JalanRusakModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.points,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'deskripsi': deskripsi,
    'points': points
        .map((e) => {'lat': e.latitude, 'lng': e.longitude})
        .toList(),
  };

  factory JalanRusakModel.fromJson(Map<String, dynamic> json) {
    return JalanRusakModel(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      points: (json['points'] as List)
          .map((e) => LatLng(e['lat'], e['lng']))
          .toList(),
    );
  }
}
