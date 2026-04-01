class Doctor {
  final String doctorCode;
  final String name;
  final String? specialization;
  final String? email;
  final String? phone;
  final String? photo;
  final String? availability;

  Doctor({
    required this.doctorCode,
    required this.name,
    this.specialization,
    this.email,
    this.phone,
    this.photo,
    this.availability,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorCode: json['DoctorCode'] ?? '',
      name: json['Doctor_name'] ?? '',
      specialization: json['Specialization'],
      email: json['Doctor_email'],
      phone: json['Phone'],
      photo: json['Photo'],
      availability: json['Availability'],
    );
  }
}