class MemberModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? profilePicture;
  final String? image;
  final bool isActive;

  MemberModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.profilePicture,
    this.image,
    this.isActive = true,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'] as String,
      fullName: json['fullName'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      phone: json['phone'] as String?,
      profilePicture: json['profilePicture'] as String?,
      image: json['image'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Returns the best available profile image URL (profilePicture or image)
  String? get displayImage => profilePicture ?? image;
}
