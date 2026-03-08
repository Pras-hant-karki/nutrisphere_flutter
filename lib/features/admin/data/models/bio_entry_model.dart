class BioEntryModel {
  final String type; // 'text' or 'image'
  final String content;
  final DateTime? createdAt;

  BioEntryModel({
    required this.type,
    required this.content,
    this.createdAt,
  });

  factory BioEntryModel.fromJson(Map<String, dynamic> json) {
    return BioEntryModel(
      type: json['type'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
    };
  }

  BioEntryModel copyWith({
    String? type,
    String? content,
    DateTime? createdAt,
  }) {
    return BioEntryModel(
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
