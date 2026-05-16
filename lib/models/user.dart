class User {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String region;
  final String district;
  final String preferredLanguage;
  final String mainCrop;

  User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.region,
    required this.district,
    required this.preferredLanguage,
    required this.mainCrop,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      region: json['region'] ?? '',
      district: json['district'] ?? '',
      preferredLanguage: json['preferred_language'] ?? 'English',
      mainCrop: json['main_crop'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'region': region,
      'district': district,
      'preferred_language': preferredLanguage,
      'main_crop': mainCrop,
    };
  }
}