import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/pertanian_controller.dart';

class PertanianView extends GetView<PertanianController> {
  const PertanianView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PertanianView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PertanianView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
