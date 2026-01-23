import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/penduduk_controller.dart';

class PendudukView extends GetView<PendudukController> {
  const PendudukView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PendudukView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PendudukView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
