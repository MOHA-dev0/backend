class UserModel {
  final int id;
  final String name;
  final String phone;
  final double balance;

  final int? universityId;
  final int? academicYearId;

  final String? status;
  final String? type;
  final String? universityName;
  final bool? universityHasCalculator;
  final int? universityYearsCount;
  final String? registrationUniversityName;
  final String? academicYearName;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    this.universityId,
    this.academicYearId,
    this.status,
    this.type,
    this.universityName,
    this.universityHasCalculator,
    this.universityYearsCount,
    this.registrationUniversityName,
    this.academicYearName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      phone: json['phone'] ?? '',
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      universityId: int.tryParse(json['university_id'].toString()),
      academicYearId: int.tryParse(json['academic_year_id'].toString()),
      status: json['status'],
      type: json['type'],
      universityName: json['university']?['name'],
      universityHasCalculator: json['university'] != null 
          ? (json['university']['has_calculator'] == 1 || json['university']['has_calculator'] == true) 
          : true,
      universityYearsCount: json['university'] != null 
          ? int.tryParse(json['university']['years_count'].toString()) 
          : 4,
      registrationUniversityName: json['registration_university']?['name'],
      academicYearName: json['academic_year']?['name'],
    );
  }

  bool get isVerified => status == 'verified';

  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    double? balance,
    int? universityId,
    int? academicYearId,
    String? status,
    String? type,
    String? universityName,
    bool? universityHasCalculator,
    int? universityYearsCount,
    String? registrationUniversityName,
    String? academicYearName,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      universityId: universityId ?? this.universityId,
      academicYearId: academicYearId ?? this.academicYearId,
      status: status ?? this.status,
      type: type ?? this.type,
      universityName: universityName ?? this.universityName,
      universityHasCalculator: universityHasCalculator ?? this.universityHasCalculator,
      universityYearsCount: universityYearsCount ?? this.universityYearsCount,
      registrationUniversityName: registrationUniversityName ?? this.registrationUniversityName,
      academicYearName: academicYearName ?? this.academicYearName,
    );
  }
}
