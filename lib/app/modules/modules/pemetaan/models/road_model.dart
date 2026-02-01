import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class RoadData {
  final String id;
  final String nama;
  final String? deskripsi;
  final List<LatLng> points;
  final RoadCondition condition;
  final DateTime? createdAt;

  RoadData({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.points,
    required this.condition,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'points': points
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'condition': condition.name,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory RoadData.fromJson(String id, Map<String, dynamic> json) {
    return RoadData(
      id: id,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'],
      points: (json['points'] as List)
          .map((p) => LatLng(p['lat'], p['lng']))
          .toList(),
      condition: RoadCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => RoadCondition.rusak,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : null,
    );
  }
}

enum RoadCondition { rusak, gelap, kabupaten }

extension RoadConditionExtension on RoadCondition {
  String get label {
    switch (this) {
      case RoadCondition.rusak:
        return 'Jalan Rusak';
      case RoadCondition.gelap:
        return 'Jalan Gelap';
      case RoadCondition.kabupaten:
        return 'Jalan Kabupaten';
    }
  }

  Color get color {
    switch (this) {
      case RoadCondition.rusak:
        return const Color(0xFFEF4444); // Red
      case RoadCondition.gelap:
        return const Color(0xFFF59E0B); // Orange/Yellow
      case RoadCondition.kabupaten:
        return const Color(0xFF3B82F6); // Blue
    }
  }
}
