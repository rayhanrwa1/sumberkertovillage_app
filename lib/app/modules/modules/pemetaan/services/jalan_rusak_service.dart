import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/jalan_rusak_model.dart';

class JalanRusakService {
  // GANTI dengan endpoint backend kamu
  static const String baseUrl =
      'https://api.sumberkerto-smart-village.id/jalan-rusak';

  /// ===============================
  /// SIMPAN JALAN RUSAK
  /// ===============================
  Future<void> saveJalanRusak(JalanRusakModel model) async {
    final response = await http.post(
      Uri.parse('$baseUrl/store'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menyimpan jalan rusak');
    }
  }

  /// ===============================
  /// AMBIL SEMUA JALAN RUSAK
  /// ===============================
  Future<List<JalanRusakModel>> fetchAllJalanRusak() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data jalan rusak');
    }

    final List data = jsonDecode(response.body);

    return data.map((e) => JalanRusakModel.fromJson(e)).toList();
  }
}
