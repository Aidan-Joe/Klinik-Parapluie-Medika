import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../models/user.dart';
import '../models/appointment.dart';
import '../models/medicalrecord.dart';
import '../models/patient.dart';
import '../models/room.dart';
import '../models/doctor.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.5:1234/api";

  static String? cookie;

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    if (cookie != null) "Cookie": cookie!,
  };

  // ================= AUTH =================

  static Future<User> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      cookie = res.headers['set-cookie'];
      return User.fromJson(jsonDecode(res.body));
    }

    throw Exception("Login gagal");
  }

  static Future<void> logout() async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/logout"),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception("Logout gagal");
    }

    cookie = null;
  }

  // ================= APPOINTMENTS =================

  static Future<List<Appointment>> getAppointments() async {
    final res = await http.get(
      Uri.parse("$baseUrl/appointments"),
      headers: headers,
    );

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
    final res = await http.post(
      Uri.parse("$baseUrl/appointments"),
      headers: headers,
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
    String code,
    String status,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/appointments/$code"),
      headers: headers,
      body: jsonEncode({"status": status}),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal update status");
    }
  }

  // ================= PATIENT =================

  static Future<List<Patient>> getPatients() async {
    final res = await http.get(
      Uri.parse("$baseUrl/patients"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Patient.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil patient");
  }

  static Future<Patient> getMyProfile(String patientCode) async {
    final res = await http.get(
      Uri.parse("$baseUrl/patients/$patientCode"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      return Patient.fromJson(jsonDecode(res.body));
    }

    throw Exception("Gagal ambil profile");
  }

  // ================= MEDICAL RECORD =================

  static Future<List<MedicalRecord>> getMedicalRecords() async {
    final res = await http.get(
      Uri.parse("$baseUrl/medicalrecords"),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => MedicalRecord.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil medical record");
  }

  static Future<void> createMedicalRecord(Map data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/medicalrecords"),
      headers: headers,
      body: jsonEncode(data),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Gagal tambah record");
    }
  }

  static Future<void> updateMedicalRecord(String code, Map data) async {
    final res = await http.put(
      Uri.parse("$baseUrl/medicalrecords/$code"),
      headers: headers,
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal update record");
    }
  }

  // ================= ROOM =================

  static Future<List<Room>> getRooms() async {
    final res = await http.get(Uri.parse("$baseUrl/rooms"), headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Room.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil room");
  }

  // ================= DOCTOR =================

  static Future<List<Doctor>> getDoctors() async {
    final res = await http.get(Uri.parse("$baseUrl/doctors"), headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Doctor.fromJson(e)).toList();
    }

    throw Exception("Gagal ambil doctor");
  }

  // 🔥 FIX FINAL
  static Future<void> updateDoctorStatus(
    Doctor doctor,
    String availability,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/doctors/${doctor.doctorCode}"),
      headers: headers,
      body: jsonEncode({
        "Doctor_email": doctor.email ?? "",
        "Password": "doctor123",
        "Specialization": doctor.specialization ?? "",
        "Phone": doctor.phone ?? "",
        "Availability": availability,
      }),
    );

    print("STATUS CODE: ${res.statusCode}");
    print("STATUS BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Gagal update status dokter");
    }
  }

  // ================= UPLOAD PHOTO =================

  static Future<void> updateDoctorPhotoFile(
    String doctorCode,
    File file,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/doctors/$doctorCode/photo"),
    );

    if (cookie != null) {
      request.headers['Cookie'] = cookie!;
    }

    request.files.add(await http.MultipartFile.fromPath('photo', file.path));

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("Upload foto gagal");
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
