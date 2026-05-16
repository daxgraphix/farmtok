class CropScan {
  final String id;
  final String userId;
  final String imageUrl;
  final String diseaseName;
  final double confidence;
  final String treatment;
  final String prevention;
  final DateTime createdAt;

  CropScan({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.diseaseName,
    required this.confidence,
    required this.treatment,
    required this.prevention,
    required this.createdAt,
  });

  factory CropScan.fromJson(Map<String, dynamic> json) {
    return CropScan(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      diseaseName: json['disease_name'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      treatment: json['treatment'] ?? '',
      prevention: json['prevention'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'disease_name': diseaseName,
      'confidence': confidence,
      'treatment': treatment,
      'prevention': prevention,
      'created_at': createdAt.toIso8601String(),
    };
  }
}