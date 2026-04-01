import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/appointment.dart';
import '../models/medicalrecord.dart';
import '../models/patient.dart';
import '../models/room.dart';
import '../models/doctor.dart';

class ApiService {
  static const String baseUrl = "http://192.168.18.66:1234/api";

  static BrowserClient get client {
    final c = BrowserClient();
    c.withCredentials = true;
    return c;
  }

  // ─── AUTH ─────────────────────────────────────────────────────────────────

  static Future<User> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final setCookie = res.headers['set-cookie'];
      if (setCookie != null) _sessionCookie = setCookie.split(';').first;
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception('Login failed');
  }

  static Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/auth/logout'), headers: _getHeaders);
    _sessionCookie = null;
  }

  // ─── APPOINTMENTS ─────────────────────────────────────────────────────────

  static Future<List<Appointment>> getAppointments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: _getHeaders,
    );
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Appointment.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil appointment");
    }
  }

  static Future<List<Patient>> getPatients() async {
    final res = await http.get(
      Uri.parse('$baseUrl/patients'),
      headers: _getHeaders,
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => Patient.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load patients');
  }

  static Future<Patient> getMyProfile(String patientCode) async {
    final res = await http.get(
      Uri.parse('$baseUrl/patients/$patientCode'),
      headers: _getHeaders,
    );
    if (res.statusCode == 200) return Patient.fromJson(jsonDecode(res.body));
    throw Exception('Failed to load profile');
  }

  // ─── MEDICAL RECORDS ──────────────────────────────────────────────────────

  static Future<List<MedicalRecord>> getMedicalRecords() async {
    final res = await client.get(Uri.parse("$baseUrl/medical-records"));

    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => MedicalRecord.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load medical records');
  }

  // ─── ROOMS ────────────────────────────────────────────────────────────────

  static Future<List<Room>> getRooms() async {
    final res = await http.get(
      Uri.parse('$baseUrl/rooms'),
      headers: _getHeaders,
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => Room.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load rooms');
  }

  // ─── DOCTORS ──────────────────────────────────────────────────────────────

  static Future<List<Doctor>> getDoctors() async {
    final res = await http.get(
      Uri.parse('$baseUrl/doctors'),
      headers: _getHeaders,
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => Doctor.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load doctors');
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

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
