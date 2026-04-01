class MedicalRecord {
  final String recordCode;
  final String doctorCode;
  final String patientCode;
  final String visitDate;
  final String diagnosis;
  final String treatment;
  final String prescription;

  MedicalRecord({
    required this.recordCode,
    required this.doctorCode,
    required this.patientCode,
    required this.visitDate,
    required this.diagnosis,
    required this.treatment,
    required this.prescription,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      recordCode: json['RecordCode'] ?? "",
      doctorCode: json['DoctorCode'] ?? "",
      patientCode: json['Patientcode'] ?? "",
      visitDate: json['Visit_date'] ?? "", 
      diagnosis: json['Diagnosis'] ?? "",
      treatment: json['Treatment'] ?? "",
      prescription: json['Prescription'] ?? "",
    );
  }
}