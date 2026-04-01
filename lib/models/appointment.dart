class Appointment {
  final String appointmentCode;
  final String patientCode;
  final String doctorCode;
  final String date;
  final String time;
  final String status;
  final String? roomCode;
  final String? symptoms;

  Appointment({
    required this.appointmentCode,
    required this.patientCode,
    required this.doctorCode,
    required this.date,
    required this.time,
    required this.status,
    this.roomCode,
    this.symptoms,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentCode: json['Appointmentcode'] ?? "",
      patientCode: json['Patientcode'] ?? "",
      doctorCode: json['DoctorCode'] ?? "",
      date: json['Appointment_date'] ?? "",
      time: json['Appointment_time'] ?? "",
      roomCode: json['Room_Code'],
      status: json['Status'] ?? "",
      symptoms: json['Symptoms'],
    );
  }
}
