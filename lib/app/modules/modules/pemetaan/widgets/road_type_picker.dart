import 'package:flutter/material.dart';
import '../models/road_model.dart';

class RoadTypePicker extends StatelessWidget {
  final Function(RoadCondition) onSelected;

  const RoadTypePicker({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: const Text('Jalan Rusak'),
            onTap: () => onSelected(RoadCondition.rusak),
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb, color: Colors.black),
            title: const Text('Tidak Ada Penerangan'),
            onTap: () => onSelected(RoadCondition.gelap),
          ),
          ListTile(
            leading: const Icon(Icons.add_road_sharp, color: Colors.blue),
            title: const Text('Jalan Kabupaten'),
            onTap: () => onSelected(RoadCondition.kabupaten),
          ),
        ],
      ),
    );
  }
}
