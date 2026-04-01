import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/doctor.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/doctor_navbar.dart';
import '../../login_page.dart';

import 'doctor_home.dart';
import 'doctor_appointment.dart';
import 'doctor_patient_list.dart';
import 'doctor_medical_record.dart';

class DoctorProfilePage extends StatefulWidget {
  final User user;
  const DoctorProfilePage({super.key, required this.user});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  Doctor? doctor;
  bool isLoading = true;
  bool isAvailable = false;

  int currentIndex = 4;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  // ================= FETCH =================
  Future<void> fetch() async {
    final doctors = await ApiService.getDoctors();

    doctor = doctors.firstWhere(
      (d) => d.doctorCode == widget.user.code,
      orElse: () => Doctor(
        doctorCode: "",
        name: "",
        photo: null,
      ),
    );

    // ✅ FIX: pakai availability + huruf besar
    isAvailable = doctor?.availability == "Available";

    setState(() => isLoading = false);
  }

  // ================= UPDATE STATUS =================
  void updateStatus(bool value) async {
    setState(() => isAvailable = value);

    try {
      await ApiService.updateDoctorStatus(
        widget.user.code,
        value ? "Available" : "Not Available",
      );
    } catch (e) {
      print("ERROR STATUS: $e");
    }
  }

  // ================= UPDATE PHOTO =================
  void updatePhoto() async {
    String newPhoto = "/uploads/default.png";

    try {
      await ApiService.updateDoctorPhoto(
        widget.user.code,
        newPhoto,
      );

      await fetch();
    } catch (e) {
      print("ERROR PHOTO: $e");
    }
  }

  // ================= LOGOUT =================
  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (_) => false,
              );
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE =================
  String img(String? path) {
    if (path == null || path.isEmpty) return "";
    return "http://localhost:1234$path";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FAF7),

      // ================= NAVBAR =================
      bottomNavigationBar: DoctorNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => DoctorHome(user: widget.user)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoctorAppointmentPage(user: widget.user)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoctorPatientListPage(user: widget.user)),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoctorMedicalRecordPage(user: widget.user)),
              );
              break;
            case 4:
              break;
          }
        },
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [

            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      name: widget.user.name,
                      photoUrl: img(doctor?.photo),
                      radius: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Clinic Parapluie",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF00261B),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.notifications, color: Color(0xFF00261B)),
              ],
            ),

            SizedBox(height: 30),

            // ================= PROFILE CARD =================
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF00261B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ProfileAvatar(
                    name: widget.user.name,
                    photoUrl: img(doctor?.photo),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.user.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Doctor",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: updatePhoto,
                    child: Text("Change Photo"),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ================= STATUS =================
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Availability",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: isAvailable,
                    onChanged: updateStatus,
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ================= INFO =================
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _info("Doctor ID", widget.user.code),
                  _info("Email", doctor?.email ?? "-"),
                  _info("Specialization", doctor?.specialization ?? "-"),
                ],
              ),
            ),

            SizedBox(height: 30),

            // ================= LOGOUT =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}