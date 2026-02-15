class PlanRequestModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userProfilePicture;
  final String? userImage;
  final String requestType;
  final String height;
  final String weight;
  final String job;
  final String foodAllergy;
  final String dietType;
  final String medicalCondition;
  final String trainingType;
  final String goal;
  final String specialRequest;
  final String status;
  final AdminResponseModel? adminResponse;
  final String? rejectionReason;
  final DateTime createdAt;

  PlanRequestModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userProfilePicture,
    this.userImage,
    required this.requestType,
    required this.height,
    required this.weight,
    required this.job,
    required this.foodAllergy,
    required this.dietType,
    required this.medicalCondition,
    required this.trainingType,
    required this.goal,
    required this.specialRequest,
    required this.status,
    this.adminResponse,
    this.rejectionReason,
    required this.createdAt,
  });

  factory PlanRequestModel.fromJson(Map<String, dynamic> json) {
    // userId can be a populated object or a plain string
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

    return PlanRequestModel(
      id: json['_id'] as String,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userProfilePicture: userProfilePicture,
      userImage: userImage,
      requestType: json['requestType'] as String? ?? 'diet',
      height: json['height'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      job: json['job'] as String? ?? '',
      foodAllergy: json['foodAllergy'] as String? ?? 'None',
      dietType: json['dietType'] as String? ?? 'veg',
      medicalCondition: json['medicalCondition'] as String? ?? 'No',
      trainingType: json['trainingType'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      specialRequest: json['specialRequest'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      adminResponse: json['adminResponse'] != null
          ? AdminResponseModel.fromJson(
              json['adminResponse'] as Map<String, dynamic>)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String? get displayImage => userProfilePicture ?? userImage;

  String get displayName => userName ?? 'Unknown User';
}

class AdminResponseModel {
  final String type;
  final String url;
  final DateTime? respondedAt;

  AdminResponseModel({
    required this.type,
    required this.url,
    this.respondedAt,
  });

  factory AdminResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminResponseModel(
      type: json['type'] as String? ?? 'file',
      url: json['url'] as String? ?? '',
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }
}
