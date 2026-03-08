class AppointmentModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userProfilePicture;
  final String? userImage;
  final String height;
  final String weight;
  final String job;
  final String trainingType;
  final String goal;
  final String preferredDate;
  final String preferredTime;
  final String country;
  final String specialRequest;
  final String status;
  final AppointmentAdminResponse? adminResponse;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userProfilePicture,
    this.userImage,
    required this.height,
    required this.weight,
    required this.job,
    required this.trainingType,
    required this.goal,
    required this.preferredDate,
    required this.preferredTime,
    required this.country,
    required this.specialRequest,
    required this.status,
    this.adminResponse,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final userIdData = json['userId'];
    String userId;
    String? userName;
    String? userEmail;
    String? userPhone;
    String? userProfilePicture;
    String? userImage;

    if (userIdData is Map<String, dynamic>) {
      userId = userIdData['_id'] as String? ?? '';
      userName = userIdData['fullName'] as String?;
      userEmail = userIdData['email'] as String?;
      userPhone = userIdData['phone'] as String?;
      userProfilePicture = userIdData['profilePicture'] as String?;
      userImage = userIdData['image'] as String?;
    } else {
      userId = userIdData as String? ?? '';
    }

    return AppointmentModel(
      id: json['_id'] as String,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userProfilePicture: userProfilePicture,
      userImage: userImage,
      height: json['height'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      job: json['job'] as String? ?? '',
      trainingType: json['trainingType'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      preferredDate: json['preferredDate'] as String? ?? '',
      preferredTime: json['preferredTime'] as String? ?? '',
      country: json['country'] as String? ?? '',
      specialRequest: json['specialRequest'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      adminResponse: json['adminResponse'] != null
          ? AppointmentAdminResponse.fromJson(
              json['adminResponse'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String? get displayImage => userProfilePicture ?? userImage;
  String get displayName => userName ?? 'Unknown User';
}

class AppointmentAdminResponse {
  final String message;
  final DateTime? respondedAt;

  AppointmentAdminResponse({
    required this.message,
    this.respondedAt,
  });

  factory AppointmentAdminResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentAdminResponse(
      message: json['message'] as String? ?? '',
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }
}
