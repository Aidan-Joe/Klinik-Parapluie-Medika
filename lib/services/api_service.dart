import 'dart:convert';
import 'package:http/browser_client.dart';

import '../models/user.dart';
import '../models/appointment.dart';
import '../models/medicalrecord.dart';
import '../models/patient.dart';
import '../models/room.dart';
import '../models/doctor.dart';

class ApiService {
  static const String baseUrl = "http://localhost:1234/api";

  // ================= CLIENT =================
  static BrowserClient get client {
    final c = BrowserClient();
    c.withCredentials = true;
    return c;
  }

  // ================= AUTH =================

  static Future<User> login(String email, String password) async {
    final res = await client.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }

    throw Exception("Login gagal");
  }

  static Future<void> logout() async {
    final res = await client.post(Uri.parse("$baseUrl/auth/logout"));

    if (res.statusCode != 200) {
      throw Exception("Logout gagal");
    }
  }

  // ================= APPOINTMENTS =================

  static Future<List<Appointment>> getAppointments() async {
    final res = await client.get(Uri.parse("$baseUrl/appointments"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Appointment.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil appointment");
  }

  static Future<void> createAppointment({
    required String doctorCode,
    required String date,
    required String time,
    String? symptoms,
  }) async {
    final res = await client.post(
      Uri.parse("$baseUrl/appointments"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "doctor_code": doctorCode,
        "date": date,
        "time": time,
        "symptoms": symptoms,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Gagal membuat appointment");
    }
  }

  static Future<void> updateAppointmentStatus(
      String code, String status) async {
    final res = await client.put(
      Uri.parse("$baseUrl/appointments/$code"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "status": status,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal update status");
    }
  }

  // ================= PATIENT =================

  static Future<List<Patient>> getPatients() async {
    final res = await client.get(Uri.parse("$baseUrl/patients"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Patient.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil patient");
  }

  static Future<Patient> getMyProfile(String patientCode) async {
    final res =
        await client.get(Uri.parse("$baseUrl/patients/$patientCode"));

    if (res.statusCode == 200) {
      return Patient.fromJson(jsonDecode(res.body));
    }

    throw Exception("Gagal ambil profile");
  }

  // ================= MEDICAL RECORD =================

  static Future<List<MedicalRecord>> getMedicalRecords() async {
    final res =
        await client.get(Uri.parse("$baseUrl/medicalrecords"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => MedicalRecord.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil medical record");
  }

  static Future<void> createMedicalRecord(Map data) async {
    final res = await client.post(
      Uri.parse("$baseUrl/medicalrecords"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("CREATE STATUS: ${res.statusCode}");
    print("CREATE BODY: ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Gagal tambah record");
    }
  }

  static Future<void> updateMedicalRecord(String code, Map data) async {
    final res = await client.put(
      Uri.parse("$baseUrl/medicalrecords/$code"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("UPDATE STATUS: ${res.statusCode}");
    print("UPDATE BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Gagal update record");
    }
  }

  // ================= ROOM =================

  static Future<List<Room>> getRooms() async {
    final res = await client.get(Uri.parse("$baseUrl/rooms"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Room.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil room");
  }

  // ================= DOCTOR =================

  static Future<List<Doctor>> getDoctors() async {
    final res = await client.get(Uri.parse("$baseUrl/doctors"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Doctor.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil doctor");
  }

  // ================= DOCTOR UPDATE =================

// UPDATE STATUS
static Future<void> updateDoctorStatus(
  String doctorCode,
  String status,
) async {
  final res = await client.put(
    Uri.parse("$baseUrl/doctors/$doctorCode/status"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"status": status}),
  );

  if (res.statusCode != 200) {
    print("STATUS ERROR: ${res.body}");
    throw Exception("Gagal update status dokter");
  }
}

// UPDATE PHOTO
static Future<void> updateDoctorPhoto(
  String doctorCode,
  String photo,
) async {
  final res = await client.put(
    Uri.parse("$baseUrl/doctors/$doctorCode/photo"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"photo": photo}),
  );

  if (res.statusCode != 200) {
    print("PHOTO ERROR: ${res.body}");
    throw Exception("Gagal update foto dokter");
  }
}

  // ================= HELPERS =================

  static String getPatientName(String code, List<Patient> patients) {
    try {
      return patients.firstWhere((p) => p.patientCode == code).name;
    } catch (_) {
      return code;
    }
  }

  static String getDoctorName(String code, List<Doctor> doctors) {
    try {
      return doctors.firstWhere((d) => d.doctorCode == code).name;
    } catch (_) {
      return code;
    }
  }
}