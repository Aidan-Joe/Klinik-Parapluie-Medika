class Patient {
  final String patientCode;
  final String name;
  final String? email;
  final String? phone;
  final String? birthdate;
  final String? gender;
  final String? address;
  final String? photo;

  Patient({
    required this.patientCode,
    required this.name,
    this.email,
    this.phone,
    this.birthdate,
    this.gender,
    this.address,
    this.photo,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientCode: json['Patientcode'] ?? "",
      name: json['Patient_name'] ?? "",
      email: json['Patient_email'], 
      phone: json['Phone'],
      birthdate: json['Birthdate'],
      gender: json['Gender'],
      address: json['Address'],
      photo: json['Photo'],
    );
  }
}