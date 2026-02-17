class EsuratModel {
  String id;
  String type;
  bool generate;
  String status;
  int createdAt;
  Map<String, dynamic> data;
  String nomor;
  String fileUrl;

  EsuratModel({
    required this.id,
    required this.type,
    required this.generate,
    required this.status,
    required this.createdAt,
    required this.data,
    required this.nomor,
    required this.fileUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "generate": generate,
      "status": status,
      "created_at": createdAt,
      "data": data,
      "nomor": nomor,
      "file_url": fileUrl,
    };
  }

  factory EsuratModel.fromJson(String id, Map data) {
    return EsuratModel(
      id: id,
      type: data['type'] ?? "",
      generate: data['generate'] ?? false,
      status: data['status'] ?? "",
      createdAt: data['created_at'] ?? 0,
      nomor: data['nomor'] ?? "",
      fileUrl: data['file_url'] ?? "",
      data: Map<String, dynamic>.from(data['data'] ?? {}),
    );
  }
}
