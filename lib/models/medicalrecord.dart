class MedicalRecord {
  final String recordCode;
  final String patientCode;
  final String doctorCode;
  final String diagnosis;
  final String treatment;
  final String prescription;
  final String visitDate;

  MedicalRecord({
    required this.recordCode,
    required this.patientCode,
    required this.doctorCode,
    required this.diagnosis,
    required this.treatment,
    required this.prescription,
    required this.visitDate,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      recordCode: json['RecordCode'] ?? "",
      patientCode: json['Patientcode'] ?? "",
      doctorCode: json['DoctorCode'] ?? "",
      diagnosis: json['Diagnosis'] ?? "",
      treatment: json['Treatment'] ?? "",
      prescription: json['Prescription'] ?? "",
      visitDate: json['VisitDate'] ?? "",
    );
  }
}