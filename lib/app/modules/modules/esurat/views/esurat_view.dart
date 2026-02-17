import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/esurat_controller.dart';

class EsuratView extends GetView<EsuratController> {
  const EsuratView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EsuratView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'EsuratView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
