class TrainerInfoModel {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? profilePicture;
  final List<TrainerBioEntry> bio;

  TrainerInfoModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.profilePicture,
    this.bio = const [],
  });

  factory TrainerInfoModel.fromJson(Map<String, dynamic> json) {
    return TrainerInfoModel(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] != null
          ? (json['bio'] as List)
              .map((e) => TrainerBioEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class TrainerBioEntry {
  final String type;
  final String content;

  TrainerBioEntry({required this.type, required this.content});

  factory TrainerBioEntry.fromJson(Map<String, dynamic> json) {
    return TrainerBioEntry(
      type: json['type'] as String,
      content: json['content'] as String,
    );
  }
}
