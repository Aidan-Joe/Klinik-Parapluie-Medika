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

  // 🔥 helper client (sekali bikin, dipakai semua)
  static BrowserClient get client {
    final c = BrowserClient();
    c.withCredentials = true;
    return c;
  }

  static Future<User> login(String email, String password) async {
    final res = await client.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Login gagal");
    }
  }

  static Future<List<Appointment>> getAppointments() async {
    final res = await client.get(Uri.parse("$baseUrl/appointments"));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Appointment.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil appointment");
    }
  }

  static Future<List<Patient>> getPatients() async {
    final res = await client.get(Uri.parse("$baseUrl/patients"));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Patient.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil patient");
    }
  }

  static Future<List<MedicalRecord>> getMedicalRecords() async {
    final res = await client.get(Uri.parse("$baseUrl/medical-records"));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => MedicalRecord.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil medical record");
    }
  }

  static Future<List<Room>> getRooms() async {
    final res = await client.get(Uri.parse("$baseUrl/rooms"));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Room.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil room");
    }
  }

  static String getPatientName(String code, List<Patient> patients) {
    try {
      return patients.firstWhere((p) => p.patientCode == code).name;
    } catch (e) {
      return code;
    }
  }

  static Future<List<Doctor>> getDoctors() async {
    final res = await client.get(Uri.parse("$baseUrl/doctors"));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Doctor.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil doctor");
    }
  }
}
